#!/usr/bin/env ruby
# frozen_string_literal: true

# Intelligent script to regenerate RBI files for changed Ruby classes
# Usage: ruby regenerate_rbi_smart.rb [base_branch] [--dry-run] [--verbose]
# Default base_branch is 'main'

require 'set'

# Parse arguments
args = ARGV.dup
show_help = args.delete('--help') || args.delete('-h')
dry_run = args.delete('--dry-run')
verbose = args.delete('--verbose') || args.delete('-v')
base_branch = args.first || 'main'

if show_help
  puts "RBI Regeneration Script"
  puts "=" * 80
  puts
  puts "Automatically regenerates RBI files for changed Ruby classes."
  puts
  puts "Considers all modified files:"
  puts "  - Committed changes (vs base branch)"
  puts "  - Staged changes"
  puts "  - Unstaged changes"
  puts "  - Untracked new files"
  puts
  puts "Usage: #{File.basename($0)} [base_branch] [options]"
  puts
  puts "Arguments:"
  puts "  base_branch     Branch to compare against (default: main)"
  puts
  puts "Options:"
  puts "  --dry-run       Preview changes without executing"
  puts "  --verbose, -v   Show detailed output"
  puts "  --help, -h      Show this help message"
  puts
  puts "Examples:"
  puts "  #{File.basename($0)}                    # Compare against main"
  puts "  #{File.basename($0)} develop           # Compare against develop"
  puts "  #{File.basename($0)} --dry-run         # Preview only"
  puts "  #{File.basename($0)} --verbose         # Show all details"
  puts "  #{File.basename($0)} develop -v --dry-run"
  puts
  exit 0
end

puts "RBI Regeneration Script"
puts "=" * 80
puts "Base branch: #{base_branch}"
puts "Mode: #{dry_run ? 'DRY RUN' : 'EXECUTE'}"
puts

# Get all changed Ruby files from all sources:
# - Committed changes (vs base branch)
# - Staged changes (in index)
# - Unstaged changes (in working directory)
# - Untracked new files
changed_files = Set.new
deleted_files = Set.new

# Files changed in current branch vs base branch
`git diff --name-only #{base_branch}...HEAD`.split("\n").each do |file|
  changed_files << file if file.end_with?('.rb')
end

# Deleted files in current branch vs base branch
`git diff --name-only --diff-filter=D #{base_branch}...HEAD`.split("\n").each do |file|
  deleted_files << file if file.end_with?('.rb')
end

# Staged files
`git diff --cached --name-only`.split("\n").each do |file|
  changed_files << file if file.end_with?('.rb')
end

# Staged deleted files
`git diff --cached --name-only --diff-filter=D`.split("\n").each do |file|
  deleted_files << file if file.end_with?('.rb')
end

# Unstaged files
`git diff --name-only`.split("\n").each do |file|
  changed_files << file if file.end_with?('.rb')
end

# Unstaged deleted files
`git diff --name-only --diff-filter=D`.split("\n").each do |file|
  deleted_files << file if file.end_with?('.rb')
end

# Untracked files (new files not yet added to git)
untracked_ruby_files = `git ls-files --others --exclude-standard`.split("\n").select { |f| f.end_with?('.rb') }
if verbose && untracked_ruby_files.any?
  puts "Found #{untracked_ruby_files.size} untracked Ruby file(s):"
  untracked_ruby_files.sort.each { |f| puts "  - #{f}" }
  puts
end
untracked_ruby_files.each { |file| changed_files << file }

# Filter out test files and normalize paths for changed files
ruby_files = changed_files.reject do |file|
  file.include?('/test/') || file.end_with?('_test.rb')
end.map do |file|
  # Remove 'areas/core/shopify/' prefix if present since we're already in that directory
  file.sub(%r{^areas/core/shopify/}, '')
end.select do |file|
  File.exist?(file)
end

# Filter out test files and normalize paths for deleted files
deleted_ruby_files = deleted_files.reject do |file|
  file.include?('/test/') || file.end_with?('_test.rb')
end.map do |file|
  # Remove 'areas/core/shopify/' prefix if present since we're already in that directory
  file.sub(%r{^areas/core/shopify/}, '')
end

if verbose && ruby_files.any?
  puts "Found #{ruby_files.size} Ruby file(s) that may need RBI regeneration:"
  ruby_files.sort.each { |f| puts "  - #{f}" }
  puts
end

if verbose && deleted_ruby_files.any?
  puts "Found #{deleted_ruby_files.size} deleted Ruby file(s):"
  deleted_ruby_files.sort.each { |f| puts "  - #{f}" }
  puts
end

if ruby_files.empty? && deleted_ruby_files.empty?
  puts "No Ruby files found that need RBI regeneration or deletion."
  exit 0
end

# Map a source Ruby file to its corresponding RBI file path
def source_to_rbi_path(source_file)
  # Pattern: components/delivery/app/tasks/delivery/maintenance/foo.rb
  # -> sorbet/rbi/dsl/delivery/maintenance/foo.rbi
  #
  # Pattern: components/delivery/app/services/delivery/domain/foo.rb
  # -> sorbet/rbi/dsl/delivery/domain/foo.rbi
  #
  # The pattern is: take everything after /app/[subdirectory]/ and prepend sorbet/rbi/dsl/

  # Find the part after '/app/[subdirectory]/' (e.g., /app/tasks/, /app/services/, /app/models/)
  if source_file =~ %r{/app/[^/]+/(.+)\.rb$}
    relative_path = $1
    return "sorbet/rbi/dsl/#{relative_path}.rbi"
  end

  nil
end

# Extract top-level class names from files
# Only extracts classes directly under modules (not nested inside other classes)
def extract_class_names(file_path)
  return [] unless File.exist?(file_path)

  content = File.read(file_path)
  class_names = []
  stack = [] # Stack of {type: :module/:class, name: "Name"}

  content.each_line do |line|
    # Match module/class declarations
    if line =~ /^\s*(module|class)\s+([A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*)/
      type = $1.to_sym
      name = $2

      # Skip fully qualified parent classes (e.g., class Foo < ::Operation)
      next if name.start_with?('::')

      # Check if we're already inside a class (nested class)
      inside_class = stack.any? { |item| item[:type] == :class }

      # Build the fully qualified name
      full_name = (stack.map { |item| item[:name] } + [name]).join('::')

      # Only add classes that are not nested inside other classes
      if type == :class && !inside_class
        class_names << full_name
      end

      # Push to stack
      stack << { type: type, name: name }

    elsif line =~ /^\s*end\s*$/
      # Pop from stack
      stack.pop unless stack.empty?
    end
  end

  class_names
end

# Collect all class names
all_class_names = []
class_file_mapping = {} # Track which classes came from which files

ruby_files.each do |file|
  class_names = extract_class_names(file)
  if verbose && class_names.empty?
    puts "Note: No top-level classes found in #{file}"
  elsif verbose
    puts "#{file}:"
    class_names.each { |name| puts "  -> #{name}" }
  end

  class_names.each do |class_name|
    all_class_names << class_name
    (class_file_mapping[file] ||= []) << class_name
  end
end

puts if verbose

# Handle deleted files - remove their corresponding RBI files
deleted_rbi_files = []
if deleted_ruby_files.any?
  puts "Processing deleted files..."
  deleted_ruby_files.each do |deleted_file|
    rbi_path = source_to_rbi_path(deleted_file)
    if rbi_path && File.exist?(rbi_path)
      deleted_rbi_files << rbi_path
      if verbose
        puts "  Found RBI for deleted file #{deleted_file}:"
        puts "    -> #{rbi_path}"
      end
    elsif verbose
      puts "  No RBI found for deleted file: #{deleted_file}"
    end
  end
  puts
end

if all_class_names.empty? && deleted_rbi_files.empty?
  puts "No class names extracted from changed files and no RBI files to delete."
  puts "This could mean:"
  puts "  - Files only contain modules (no classes)"
  puts "  - Files only contain nested classes (which don't need RBI generation)"
  puts "  - Files don't follow expected Ruby structure"
  exit 0
end

# Remove duplicates
all_class_names.uniq!

puts "Summary:"
puts "  #{ruby_files.size} Ruby file(s) changed"
puts "  #{all_class_names.size} top-level class(es) found"
puts "  #{deleted_ruby_files.size} Ruby file(s) deleted"
puts "  #{deleted_rbi_files.size} RBI file(s) to delete"
puts

if dry_run
  puts "DRY RUN - Would execute:"
  if all_class_names.any?
    puts "/opt/dev/bin/dev rbi dsl #{all_class_names.join(' ')}"
    puts
    puts "Classes to process:"
    all_class_names.sort.each { |name| puts "  - #{name}" }
    puts
  end
  if deleted_rbi_files.any?
    puts "RBI files to delete:"
    deleted_rbi_files.sort.each { |file| puts "  - #{file}" }
  end
  exit 0
end

# Capture git status before
rbi_files_before = `git diff --name-only`.split("\n").select { |f| f.end_with?('.rbi') }.to_set

# Run dev rbi dsl with all class names if any exist
exit_code = 0
if all_class_names.any?
  puts "Running: /opt/dev/bin/dev rbi dsl #{all_class_names.join(' ')}"
  puts
  system("/opt/dev/bin/dev", "rbi", "dsl", *all_class_names)
  exit_code = $?.exitstatus
end

# Delete RBI files for deleted source files
actually_deleted_rbi_files = []
if deleted_rbi_files.any?
  puts "Deleting RBI files for deleted source files..."
  deleted_rbi_files.each do |rbi_file|
    if File.exist?(rbi_file)
      File.delete(rbi_file)
      actually_deleted_rbi_files << rbi_file
      puts "  Deleted: #{rbi_file}"
    end
  end
  puts
end

# Capture git status after
rbi_files_after = `git diff --name-only`.split("\n").select { |f| f.end_with?('.rbi') }.to_set

# Check what changed
new_rbi_files = rbi_files_after - rbi_files_before

puts
puts "=" * 80
puts "Results:"
puts

if exit_code == 0
  puts "✓ RBI generation completed successfully!"
else
  puts "⚠ RBI generation exited with code #{exit_code}"
  puts "  (This often happens when some classes don't need RBI generation)"
end

puts

if actually_deleted_rbi_files.any?
  puts "✓ Deleted RBI files:"
  actually_deleted_rbi_files.sort.each { |f| puts "    #{f}" }
  puts
end

if new_rbi_files.empty? && actually_deleted_rbi_files.empty?
  puts "Note: No RBI files were modified or deleted."
  puts
  puts "This is expected for:"
  puts "  - Classes without DSL methods (SmartProperties, ActiveRecord, etc.)"
  puts "  - Plain Ruby service objects"
  puts "  - Classes that don't use gems that generate RBI signatures"
  puts
  puts "Only classes using DSL features require RBI generation:"
  puts "  - ActiveRecord models with associations, validations, etc."
  puts "  - Classes using SmartProperties (property, property!)"
  puts "  - Classes using other DSL-generating gems"
elsif new_rbi_files.any?
  puts "✓ Modified RBI files:"
  new_rbi_files.sort.each { |f| puts "    #{f}" }
  puts
  puts "Run 'git diff sorbet/rbi/dsl/' to see changes."
end

puts
puts "Tip: Use --verbose to see which classes were extracted from each file"
puts "Tip: Use --dry-run to preview without executing"
