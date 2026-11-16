# I-deploy ang laro sa WEBSITE gamit ang GitHub Pages

## A. Ihanda ang project (isang beses)
    cd C:\Users\User\OneDrive\Desktop\fruit_matching_puzzle
    powershell -ExecutionPolicy Bypass -File .\web_setup.ps1
    flutter run -d chrome
## B. Git (kung wala pa)
    winget install --id Git.Git -e
(isara at buksan ulit ang terminal)
    git --version
    git config --global user.name "Pangalan Mo"
    git config --global user.email "email-mo@gmail.com"

## C. Gumawa ng repository sa github.com
New repository -> Repository name: fruit-matching-puzzle -> Public -> Create repository
(HUWAG mag-check ng README / .gitignore / license)

## D. I-push ang code (palitan ang <USERNAME>)
    cd C:\Users\User\OneDrive\Desktop\fruit_matching_puzzle
    git init
    git add .
    git commit -m "Fruit Matching Puzzle"
    git branch -M main
    git remote add origin https://github.com/<USERNAME>/fruit-matching-puzzle.git
    git push -u origin main

## E. I-on ang GitHub Pages
Repository -> Settings -> Pages -> Build and deployment -> Source: GitHub Actions

## F. Hintayin ang build
Repository -> Actions tab -> hintayin ang berdeng check (mga 3-6 minuto).
Ang website: https://<USERNAME>.github.io/fruit-matching-puzzle/

## G. Mag-update ng laro
    git add .
    git commit -m "update"
    git push
Awtomatikong mag-de-deploy ulit. (Ctrl + F5 sa browser kung luma pa ang nakikita.)
