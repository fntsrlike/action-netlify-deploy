# Netlify Deploy

This is a simple GitHub Action to deploy a static website to Netlify.

## Usage

To use a GitHub action you can just reference it on your Workflow file
(for more info check [this article by Github](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow))

```yml
name: 'My Workflow'

on:
  release:
    types: [published]

jobs:
  deploy:
    name: 'Deploy to Netlify'
    steps:
      - uses: fntsrlike/action-netlify-deploy@v2
        with:
          NETLIFY_AUTH_TOKEN: ${{ secrets.MY_TOKEN_SECRET }}
          NETLIFY_DEPLOY_TO_PROD: true
```

### Inputs

As most GitHub actions, this action requires and uses some inputs, that you define in
your workflow file.

The inputs this action uses are:

| Name | Required | Default | Description |
|:----:|:--------:|:-------:|:-----------:|
| `NETLIFY_AUTH_TOKEN` | `true` | N/A | The token needed to deploy your site ([generate here](https://app.netlify.com/user/applications#personal-access-tokens))|
| `NETLIFY_SITE_ID` | `true` | N/A | The site to where deploy your site (get it from the API ID on your Site Settings) |
| `NETLIFY_DEPLOY_MESSAGE` | `false` | '' | An optional deploy message |
| `NETLIFY_DEPLOY_TO_PROD` | `false` | `false` | Should the site be deployed to production? |
| `build_directory` | `false` | `'build'` | The directory where your files are built |
| `functions_directory` | `false` | N/A | The (optional) directory where your Netlify functions are stored |
| `install_command` | `false` | Auto-detected | The (optional) command to install dependencies. Runs `yarn` when `yarn.lock` is found; `npm i` otherwise |
| `build_command` | `false` | `npm run build` | The (optional) command to build static website |
| `deploy_alias` | `false` | '' | (Optional) [Deployed site alias](https://cli.netlify.com/commands/deploy) |


### Outputs

The outputs for this action are:

`NETLIFY_OUTPUT`

Full output of the action

`NETLIFY_PREVIEW_URL`

The url of deployment preview.

`NETLIFY_LOGS_URL`

The url of the logs.

`NETLIFY_LIVE_URL`

The url of the live deployed site.


## Example

### Deploy to production on release

> You can setup repo secrets to use in your workflows

```yml
name: 'Netlify Deploy'

on:
  release:
    types: ['published']

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: fntsrlike/action-netlify-deploy@v2
        with:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
          NETLIFY_DEPLOY_MESSAGE: "Prod deploy v${{ github.ref }}"
          NETLIFY_DEPLOY_TO_PROD: true
```

### Preview Deploy on pull request

```yml
name: 'Netlify Preview Deploy'

on:
  pull_request:
    types: ['opened', 'edited', 'synchronize']

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: fntsrlike/action-netlify-deploy@v2
        with:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}

```

### Use branch name to deploy

Will deploy branches as `https://${branchName}--${siteName}.netlify.app`.

An action is used to extract the branch name to avoid fiddling with `refs/`. Finally, a commit status check is added, linking to the deployed site.

Only the default branch is built for simplicity. Use a similar workflow or standard Netlify integration for the production deployment.

```yml
name: 'Netlify Previews'

on:
  push:
    branches-ignore:
      - master

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      # Sets the branch name as environment variable
      - uses: nelonoel/branch-name@v1.0.1
      - uses: fntsrlike/action-netlify-deploy@v2
        with:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
          deploy_alias: ${{ env.BRANCH_NAME }}

      # Creates a status check with link to preview
      - name: Status check
        uses: Sibz/github-status-action@v1.1.1
        with:
          authToken: ${{ secrets.GITHUB_TOKEN }}
          context: Netlify preview
          state: success
          target_url: ${{ env.NETLIFY_PREVIEW_URL }}
```

### Deploy to Netlify only

In case of already having the deployment ready data - we can easily skip the nvm, install and build part via passing:

```
- name: Deploy to Netlify
  uses: fntsrlike/action-netlify-deploy@v2
  with:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
    NETLIFY_DEPLOY_MESSAGE: "Deployed from GitHub action"
    NETLIFY_DEPLOY_TO_PROD: true
    install_command: "echo Skipping installing the dependencies"
    build_command: "echo Skipping building the web files"
```

## Contributors

- [tpluscode](https://github.com/tpluscode)
- [wallies](https://github.com/wallies)
- [crisperit](https://github.com/crisperit)
