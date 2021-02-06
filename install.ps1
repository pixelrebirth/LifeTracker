remove-item tasklet.db -ea 0
cp ./ ($env:psmodulepath.split(';')[0]) -Recurse -Force