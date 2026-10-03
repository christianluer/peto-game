.PHONY: start

# Launch the quest and keep it running when the window is in the background.
start:
	solarus-run -suspend-unfocused=no -lua-console=no .
