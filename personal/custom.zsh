# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.

alias g='git'

alias dump='bin/rails graphql:schema:dump'                          # Update GraphQL schema. Use `dump admin` for admin only!
alias reindex='rake elasticsearch:reindex'                          # Before reindexing elastic search, comment out the mappings not needed in elastic_search_config.rb

alias test='dev test --include-branch-commits'                      # Run rails backend tests for committed changes
alias style='dev style -a --include-branch-commits'                 # Style and format code on committed changes
alias typecheck='bundle exec srb tc'                                # :sorbet: Typecheck to ensure signatures don't go stale
alias rbis='bin/tapioca dsl'                                        # To generate the RBIs for Rails and other DSLs

alias checks='style && typecheck && test'                           # Use this before every push!

alias inv='~/dotfiles/personal/inventory.sh'                        # TODO: Investigate permission denied error.
alias ebeta='bin/rails dev:betas:enable SHOP_ID=1 BETA='            # Enable a beta flag for Shop 1
alias dbeta='bin/rails dev:betas:disable SHOP_ID=1 BETA='           # Disable a beta flag for Shop 1
