# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.

alias g='git'

alias dump='bin/rails graphql:schema:dump'                          # Update GraphQL schema. Use `dump admin` for admin only!

alias test='dev test --include-branch-commits'                      # Run rails backend tests for committed changes
alias style='dev style -a --include-branch-commits'                 # Style and format code on committed changes
alias typecheck='bin/typecheck'                                     # :sorbet: Typecheck to ensure signatures don't go stale
alias rbis='bin/tapioca dsl'                                        # To generate the RBIs for Rails and other DSLs

alias checks='style && typecheck && test'                           # Use this before every push!

alias ebeta='bin/rails dev:betas:enable SHOP_ID=1 BETA='            # Enable a beta flag for Shop 1
alias dbeta='bin/rails dev:betas:disable SHOP_ID=1 BETA='           # Disable a beta flag for Shop 1
