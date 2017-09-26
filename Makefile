default:
	elm-make --yes App.elm

publish: default
	-@git branch -D gh-pages
	git checkout -b gh-pages
	git add -f index.html
	git commit -m Publish
	git push -f origin gh-pages
	git checkout master

