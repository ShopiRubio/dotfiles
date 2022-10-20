# Custom actions to take on initial install of dotfiles.
# This runs after default install actions, so you can overwrite changes it makes if you want.
export BUILDKITE_TOKEN="$(cat /etc/spin/secrets/buildkite)"
echo "Access to Buildkite granted. You can now call bin/rails test buildkite_id"
