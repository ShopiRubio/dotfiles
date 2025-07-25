# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.

# rake -T to see all possible rake scripts! Pro tip to find something in particular: (ex: "pickup"): `bin/rake -T | grep pickup`

# Need this for local now.
# source $HOME/dotfiles/personal/custom.zsh

alias g='git'
alias tlog='tail -f log/development.log'

alias dump='bin/rails graphql:schema:dump'                          # Update GraphQL schema.
alias dumpa='dev dump-graphql admin'                                # Update Admin GraphQL schema only.
alias migrate='bin/rails db:migrate'                                # Run db migrations.
alias test_es='rake elasticsearch:update_test_mappings'             # Generates elastic search test mappings.
alias reindex='rake elasticsearch:reindex'                          

alias webhook_docs='dev generate-api-docs-openapi webhook_subscription' # Generate webhook documentation (topics.yml)

alias token='rake dev:show_access_token'                            # Show the admin app's access token for Shop 1

alias test='dev test --include-branch-commits --record-deprecations'  # Run rails backend tests for committed changes
alias coverage='test --coverage'                                    # Run rails backend tests for committed changes AND check coverage

alias style='dev style -a --include-branch-commits'                 # Style and format code on committed changes
alias typecheck='bundle exec srb tc'                                # :sorbet: Typecheck to ensure signatures don't go stale

alias to_rbs='f(){ spoom srb sigs translate "$@";  unset -f f; }; f'
alias rbis='bin/tapioca dsl'                                        # To generate the RBIs for Rails and other DSLs
alias glint='dev graphqllint'                                       # Check for GraphQL Lint violations.

alias checks='style && typecheck && coverage'                           # Use this before every push!

alias shipped='f(){ dev conveyor is-it-shipped "$@";  unset -f f; }; f'

alias find_pr='f(){ dev update 44cdfec && dev find-pr "$@" && dev update;  unset -f f; }; f'

alias vsclaude='ENABLE_IDE_INTEGRATION=true claude'

alias ntmux='f(){ tmux -CC new -A -s "$@";  unset -f f; }; f'

# Graphite
alias gtc='f(){ gt create --all --message "$@";  unset -f f; }; f'

# Verdict configure flag
alias vbeta='f(){ bundle exec verdict "$@";  unset -f f; }; f'

alias newflag='f(){ bundle exec rails g verdict:flag "$@";  unset -f f; }; f'

# Enable a beta flag
alias ebeta='f(){ bin/rails g verdict:configure_flag "$@" --subject_type "shop" --percent 100;  unset -f f; }; f'

# Disable a beta flag
alias dbeta='f(){ bin/rails g verdict:configure_flag "$@" --subject_type "shop" --percent 0;  unset -f f; }; f'      

# git first commit and push
alias cpr='f(){ g fo main && g pull origin main && g acm "$@" && pr;  unset -f f; }; f'

# git force update currently checked out branch
alias gfu='f(){ g fo main && g rebase origin/main && g push origin -f $(git rev-parse --abbrev-ref HEAD);  unset -f f; }; f'

# git add & commit, rebase from origin/main interactive and force update current branch. Example use: `gcrf "Commit message"`
alias gcrf='fu(){ g acm "$@" && g romi && gfu; unset -f fu; }; fu'

# git short for quick fix
alias qf='gcrf "fixup! fix"'

# git ask for file and line range to do a git blame and PR search - then add a line in there for AI agent :) 
gblame() { 
    echo -n "Enter the file path: "
    read file_path
    echo -n "Enter the start line (default: 1): "
    read start_line
    start_line=${start_line:-1}
    echo -n "Enter the end line (default: end of file): "
    read end_line
    
    blame_range=""
    if [ -n "$end_line" ]; then
        blame_range="-L $start_line,$end_line"
    else
        blame_range="-L $start_line"
    fi

    (
        git blame $blame_range "$file_path" | \
        while read -r line; do
            sha=$(echo "$line" | awk '{print $1}')
            echo "$line"
            echo "PR Info for $sha:"
            gh pr list --search "$sha" --state merged --json number,title,body --jq '.[] | "PR #\(.number): \(.title)\nDescription: \(.body)\n"'
            echo "-------------------"
        done

        echo ""
        echo "Given the blame and log history, why was this change made?"
    ) | pbcopy

    echo "Results have been copied to clipboard."
}

### Monorail

# List topics
alias mrl='/opt/kafka/bin/kafka-topics.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --list'

# Consume specific topic
alias mrc='f(){ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --topic "$@" | jq ".payload | fromjson";  unset -f f; }; f'

# Consume all
alias mra='/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --include "monorail_.*" | jq ". | {schema_id, event_timestamp, payload}"'

### Web (https://web.docs.shopify.io/docs/guides/continuous-integration#linting)

alias wgql='pnpm refresh-graphql'
alias wtype='pnpm type-check'
alias wtest='pnpm test --watch'
alias wchecks='wgql && wtype && wtest'

### Useful Core Rake tasks

alias quick_orders='rake dev:orders:create NUM=10 SHOP_ID=1'
alias products='NUM=10 SHOP_ID=1 rake dev:products:create'
alias dummy_orders='rake dev:orders:generate_dummy_orders SHOP_ID=1'            # takes longer, but generates lots of orders in many different states
alias plus='rake dev:shop:change_plan SHOP_ID=1 PLAN=shopify_plus'

### Troubleshooting

alias killport='f() { 
    echo "Processes running on port $1:"
    lsof -i :$1
    pid=$(lsof -ti :$1)
    if [ -z "$pid" ]; then
        echo "No process found running on port $1"
    else
        echo "Process with PID $pid is running on port $1"
        echo -n "Do you want to kill this process? (y/N) "
        read confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            kill -9 $pid
            echo "Process $pid has been killed"
        else
            echo "Operation cancelled"
        fi
    fi
}; f'

### Orderprinter

alias staging='git push origin +HEAD:staging'
