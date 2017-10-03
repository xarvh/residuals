
target = index.html
current_branch = $(shell git rev-parse --abbrev-ref HEAD)


default:
	elm-make --yes App.elm --output=$(target)


publish: default
	-@git branch -D gh-pages
	git checkout -b gh-pages
	git add -f $(target)
	git commit -m Publish
	git push -f origin gh-pages
	git checkout $(current_branch)

