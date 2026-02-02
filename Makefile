
install:
	if [ ! -d .venv ]; then virtualenv -p `which python3` .venv; fi; \
	. .venv/bin/activate; \
	python -m pip install -r requirements.txt; \
	# python -m pip freeze; \
	deactivate

run:
	. .venv/bin/activate; \
	uvicorn app.main:app --host=127.0.0.1 --port=28080 --workers 1 --reload ; \
	deactivate

flake8:
	. .venv/bin/activate; \
	flake8 . ; \
	deactivate

black:
	. .venv/bin/activate; \
	black app/main.py ; \
	deactivate
