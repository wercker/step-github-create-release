# GitHub create release step

A wercker step for creating a GitHub release. It has a few parameters, but only two are required: `token` and `tag`. See [Creating a GitHub token](#creating-a-github-token).

This step will export the id of the release in an environment variable (default: `$WERCKER_GITHUB_CREATE_RELEASE_ID`). This allows other steps to use this release, like the github-upload-asset step.

Currently this step does not do any json escaping. So be careful when using quotes or newlines in parameters.

More information about GitHub releases:

- https://github.com/blog/1547-release-your-software
- https://developer.github.com/v3/repos/releases/

# Example

A minimal example, this will get the token from a environment variable and use the hardcoded `v1.0.0` tag:

``` yaml
deploy:
    steps:
        - github-create-release:
            token: $GITHUB_TOKEN
            tag: v1.0.0
```

It is also possible to use a environment variable as a token parameter (or any parameter actually). A fictional example which gets the version of the application from `rake version`, stores it in a environment variable en finally passes it along to `github-create-release` (**for this to work, a `version` task needs to be created**):

``` yaml
deploy:
    steps:
        - script:
            name: get version from rake
            code: export APP_VERSION=$(rake version)
        - github-create-release:
            token: $GITHUB_TOKEN
            tag: $APP_VERSION
```

# Common problems

## curl: (22) The requested URL returned error: 400

GitHub has rejected the call. Most likely invalid json was used. Check to see if any of the parameters need escaping (quotes and new lines).

## curl: (22) The requested URL returned error: 401

The `token` is not valid. If using a protected environment variable, check if the token is inside the environment variable.

## curl: (22) The requested URL returned error: 422

GitHub rejected the API call. Check if the tag you are using isn't in use already.

# Creating a GitHub token

To be able to use this step, you will first need to create a GitHub token with an account which has enough permissions to be able to create releases. First goto `Account settings`, then goto `Applications` for the user. Here you can create a token in the `Personal access tokens` section. For a private repository you will need the `repo` scope and for a public repository you will need the `public_repo` scope. Then it is recommended to save this token on wercker as a protected environment variable.

# What's new

- Initial release.

# Options

- `token` The token used to make the requests to GitHub. See [Creating a GitHub token](#creating-a-github-token).
- `tag` The tag name of the release. This needs to be unique for this repository. Semver versioning is recommended, but not required. (make sure this is json encoded, see [TODO](#todo))
- `owner` (optional) The GitHub owner of the repository. Defaults to `$WERCKER_GIT_OWNER`, which is the GitHub owner of the original build.
- `repo` (optional) The name of the GitHub repository. Defaults to `$WERCKER_GIT_REPOSITORY`, which is the repository of the original build.
- `target-commitish` (optional) Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Defaults to `$WERCKER_GIT_COMMIT`, which is the commit of the original build.
- `title` (optional) The title of the release. (make sure this is json encoded, see [TODO](#todo))
- `body` (optional) Text describing the contents of the tag. (make sure this is json encoded, see [TODO](#todo))
- `draft` (optional) Create a unpublished release if this is `true`, or create a published release if this is `false`. Defaults to empty, which means the default of GitHub will be used (currently this is `false`).
- `prerelease` (optional) Create a pre-release release if this is `true`, or create a normal release if this is `false`. Defaults to empty, which means the default of GitHub will be used (currently this is `false`).
- `export-id` (optional) After the release is created, a release id will be made available in the environment variable identifier in this environment variable. Defaults to `WERCKER_GITHUB_CREATE_RELEASE_ID`.

# TODO

- Create better error handling for invalid token en existing tag.
- Escape user input to be valid json.
- Make sure `export_id` contains a valid environment variable identifier.
- Add check to see if the tag is not used for a release already.

# License

The MIT License (MIT)

# Changelog

## 2.0.0

- Update `jq` from 1.3 to 1.5

## 1.0.1

- Initial release.
