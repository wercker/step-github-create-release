
create_release() {
  set -e;

  local token="$1";
  local owner="$2";
  local repo="$3";
  local tag_name="$4";
  local target_commitish="$5";
  local name="$6";
  local body="$7";
  local draft="$8";
  local prerelease="$9";

  local payload="\"tag_name\":\"$tag_name\"";

  if [ -n "$target_commitish" ]; then
    payload="$payload,\"target_commitish\":\"$target_commitish\"";
  fi;

  if [ -n "$name" ]; then
    payload="$payload,\"name\":\"$name\"";
  fi;

  if [ -n "$body" ]; then
    payload="$payload,\"body\":\"$body\"";
  fi;

  if [ -n "$draft" ]; then
    payload="$payload,\"draft\":$draft";
  fi;

  if [ -n "$prerelease" ]; then
    payload="$payload,\"prerelease\":$prerelease";
  fi;

  payload="{$payload}";

  curl --fail -s -S -X POST https://api.github.com/repos/$owner/$repo/releases \
    -A "wercker-create-release" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d "$payload";
}

export_id_to_env_var() {
  set -e;

  local json="$1";
  local export_name="$2";

  local id=$(echo "$json" | $WERCKER_STEP_ROOT/bin/jq ".id");

  info "exporting release id ($id) to environment variable: \$$export_name";

  export $export_name=$id;
}

main() {
  set -e;

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_CREATE_RELEASE_TOKEN";
  local owner="$WERCKER_GITHUB_CREATE_RELEASE_OWNER";
  local repo="$WERCKER_GITHUB_CREATE_RELEASE_REPO";
  local tag_name="$WERCKER_GITHUB_CREATE_RELEASE_TAG";
  local target_commitish="$WERCKER_GITHUB_CREATE_RELEASE_TARGET_COMMITISH";
  local name="$WERCKER_GITHUB_CREATE_RELEASE_TITLE";
  local body="$WERCKER_GITHUB_CREATE_RELEASE_BODY";
  local draft="$WERCKER_GITHUB_CREATE_RELEASE_DRAFT";
  local prerelease="$WERCKER_GITHUB_CREATE_RELEASE_PRERELEASE";
  local export_id="$WERCKER_GITHUB_CREATE_RELEASE_EXPORT_ID";

  # Validate variables
  if [ -z "$token" ]; then
    fail "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$tag_name" ]; then
    fail "Tag name not specified; please add a tag_name parameter to the step";
  fi

  if [ -n "$draft" ]; then
    if [ "$draft" != "false" ] && [ "$draft" != "true" ]; then
      fail "The parameter draft has to be false or true";
    fi
  fi

  if [ -n "$prerelease" ]; then
    if [ "$prerelease" != "false" ] && [ "$prerelease" != "true" ]; then
      fail "The parameter prerelease has to be false or true";
    fi
  fi

  # Set variables to defaults if not set by the user
  if [ -z "$owner" ]; then
    owner="$WERCKER_GIT_OWNER";
    info "no GitHub owner was supplied; using GitHub owner of build repository: $owner";
  fi

  if [ -z "$repo" ]; then
    repo="$WERCKER_GIT_REPOSITORY";
    info "no GitHub repository was supplied; using GitHub repository of build: $repo";
  fi

  if [ -z "$target_commitish" ]; then
    target_commitish="$WERCKER_GIT_COMMIT";
    info "no target commitsh was supplied; using commit hash of the build: $target_commitish";
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_CREATE_RELEASE_ID";
    info "no export id was supplied, using default value: $export_id";
  fi

  info "starting creating release with tag $tag_name to GitHub repo $owner/$repo";

  # Create the release and save the output from curl
  RELEASE_RESPONSE=$(create_release \
    "$token" \
    "$owner" \
    "$repo" \
    "$tag_name" \
    "$target_commitish" \
    "$name" \
    "$body" \
    "$draft" \
    "$prerelease");

  info "finished creating release with tag $tag_name to GitHub repo $owner/$repo";

  export_id_to_env_var "$RELEASE_RESPONSE" "$export_id";

  info "successfully created release on GitHub";
}

# Run the main function
main;