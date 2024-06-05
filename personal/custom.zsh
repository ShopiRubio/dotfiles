# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.

# rake -T to see all possible rake scripts!

alias g='git'
alias tlog='tail -f log/development.log'

alias dump='bin/rails graphql:schema:dump'                          # Update GraphQL schema.
alias dumpa='dev dump-graphql admin'                                # Update Admin GraphQL schema only.
alias migrate='bin/rails db:migrate'                                # Run db migrations.
alias test_es='rake elasticsearch:update_test_mappings'             # Generates elastic search test mappings.
alias reindex='rake elasticsearch:reindex'                          

alias token='rake dev:show_access_token'                            # Show the admin app's access token for Shop 1

alias test='dev test --include-branch-commits'                      # Run rails backend tests for committed changes
alias coverage='dev test --include-branch-commits --coverage'       # Run rails backend tests for committed changes AND check coverage

alias style='dev style -a --include-branch-commits'                 # Style and format code on committed changes
alias typecheck='bundle exec srb tc'                                # :sorbet: Typecheck to ensure signatures don't go stale

alias rbis='bin/tapioca dsl'                                        # To generate the RBIs for Rails and other DSLs
alias glint='dev graphqllint'                                       # Check for GraphQL Lint violations.

alias checks='style && typecheck && test'                           # Use this before every push!

alias pr='dev open pr'                                              # Push current branch, set remote as upstream, open PR on GitHub!

alias merchant='f(){ dev copy-shop-settings "$@";  unset -f f; }; f' # merchant <production_shop_id>

# Enable a beta flag for Shop 1
alias ebeta='f(){ bin/rails dev:betas:enable SHOP_ID=1 BETA="$@";  unset -f f; }; f'

# Disable a beta flag for Shop 1
alias dbeta='f(){ bin/rails dev:betas:disable SHOP_ID=1 BETA="$@";  unset -f f; }; f'         

# git first commit and push
alias cpr='f(){ g fo main && g pull origin main && g acm "$@" && pr;  unset -f f; }; f'

# git force update currently checked out branch
alias gfu='f(){ g fo main && g rebase origin/main && g push origin -f $(git rev-parse --abbrev-ref HEAD);  unset -f f; }; f'

# git add & commit, rebase from origin/main interactive and force update current branch. Example use: `gcrf "Commit message"`
alias gcrf='fu(){ g acm "$@" && g romi && gfu; unset -f fu; }; fu'

# short for quick fix
alias qf='gcrf "fixup! fix"'

### Monorail

# List topics
alias mrl='/opt/kafka/bin/kafka-topics.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --list'

# Consume specific topic
alias mrc='f(){ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --topic "$@" | jq ".payload | fromjson";  unset -f f; }; f'

# Consume all
alias mra='/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server $KAFKA_AGGREGATE_BROKERS --include "monorail_.*" | jq ". | {schema_id, event_timestamp, payload}"'

### Web (https://web.docs.shopify.io/docs/guides/continuous-integration#linting)

alias wgql='yarn refresh-graphql'
alias wtype='yarn type-check'
alias wtest='yarn test --watch'
alias wchecks='wgql && wtype && wtest'

### Useful Core Rake tasks

alias quick_orders='rake dev:orders:create NUM=10 SHOP_ID=1'
alias products='NUM=10 SHOP_ID=1 rake dev:products:create'
alias dummy_orders='rake dev:orders:generate_dummy_orders SHOP_ID=1'            # takes longer, but generates lots of orders in many different states
alias plus='rake dev:shop:change_plan SHOP_ID=1 PLAN=shopify_plus'

### Orderprinter

alias staging='git push origin +HEAD:staging'
