# Installation

If you haven't already, initialize a repository and make at least commit:
```PS
git init
"" | Set-Content README.md
git add .
git commit -m "initial commit"
```

First, clone [git-subrepo](https://github.com/ingydotnet/git-subrepo) to a folder on your machine.
```PS
git clone https://github.com/ingydotnet/git-subrepo c:\src\git-subrepo
```

From a terminal session in your project, install git-subrepo locally.
```PS
$env:GIT_SUBREPO_ROOT = "c:\src\git-subrepo"
$env:Path = "$env:Path;$env:GIT_SUBREPO_ROOT\lib"
```

From that same terminal session, clone git-subrepo as a subrepo.
```PS
git subrepo clone https://github.com/ingydotnet/git-subrepo git-subrepo
```

Make a `settings.json` file in a folder called `.vscode` with the following contents:
```JSON
{
    "terminal.integrated.env.windows": {
        "GIT_SUBREPO_ROOT": "${workspaceFolder}\\git-subrepo"
    },
    "terminal.integrated.shellArgs.windows": [
        "-NoExit",
        "-Command", "$env:Path = \"$env:Path;$env:GIT_SUBREPO_ROOT\\lib\""
    ]
}
```

Clone this repository:
```PS
git subrepo clone https://github.com/tyler-hogsett-microsoft/cds-powershell-quickstart powershell -b portals
```