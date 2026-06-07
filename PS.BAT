cd C:\SAHAS_WEB
git init
git add .
git commit -m "Initial commit: SAHAS website migration"
git remote add origin https://github.com/stschand/SAHAS.git
git branch -M main
git pull origin main --allow-unrelated-histories
git push -u origin main