import os
from dotenv import load_dotenv
from pathlib import Path
import subprocess
import json
import base64
import uuid
import logging
from fastapi.responses import FileResponse, JSONResponse, PlainTextResponse, HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.openapi.docs import (
    get_swagger_ui_html,
    get_swagger_ui_oauth2_redirect_html,
)

from app.fastapi_middleware_logger.fastapi_middleware_logger import (
    add_custom_logger,
)  # noqa: E501

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    filename=os.getenv("LOG_FILE"),
    datefmt="%Y-%m-%d %H:%M:%S",
    format="%(asctime)s %(levelname)s: %(message)s",
)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

app = FastAPI(
    docs_url=None,
    redoc_url=None,
    title="vtext API",
    version="0.0.1",
)

app = add_custom_logger(app, disable_uvicorn_logging=False, external_logger_uri=None)
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")


@app.post("/auslegung-1", response_class=HTMLResponse)
async def auslegung_1(request: Request) -> None:
    form_data = await request.form()
    form_data_dict = dict(form_data)

    err_text = ""
    output_content = ""
    error_content = ""
    stderr_data = None
    stdout_data = None

    try:
        tmp_stdout_filename = "/tmp/" + str(uuid.uuid4()) + ".out.txt"
        tmp_stderr_filename = "/tmp/" + str(uuid.uuid4()) + ".err.txt"
        my_env = os.environ.copy()
        my_env['SCRIPT_DIR'] = os.getenv('SCRIPT_DIR')
        with open(tmp_stdout_filename, 'w') as stdout_file_object, open(tmp_stderr_filename, 'w') as stderr_file_object:
            process = subprocess.run(
                [Path(os.getenv('SCRIPT_DIR')) / Path(os.getenv('AUS_FORM1_SCRIPT')), json.dumps(form_data_dict),],
                stdout=stdout_file_object,
                stderr=stderr_file_object,
                encoding="utf-8",
                text=True,
                check=False,
                env=my_env
            )

        with open(tmp_stdout_filename, "r") as tmp_file:
            stdout_data = tmp_file.read()
        os.unlink(tmp_stdout_filename)

        with open(tmp_stderr_filename, "r") as tmp_file:
            stderr_data = tmp_file.read()
        os.unlink(tmp_stderr_filename)

        if stderr_data:
            logger.error(json.dumps({'error_message': stderr_data.replace("\n", " ")}, ensure_ascii=False))

        try:
            json_xdata = json.loads(stdout_data)
            try:
                output_content = base64.b64decode(json_xdata.get('output_content')).decode('utf-8')
                error_content = base64.b64decode(json_xdata.get('error_content')).decode('utf-8')
            except Exception as err:
                error_content = str(err)
        except json.decoder.JSONDecodeError as err:
            error_content = str(err)
    except subprocess.CalledProcessError as ee:
        err_text = "Error executing script"
    except FileNotFoundError:
        err_text = "Script not found. Ensure it's executable and in the correct path."

    return templates.TemplateResponse(
        "aus_page1.html", {
            "request": request,
            "output_content": output_content,
            "stderr_content": stderr_data,
            "error_content": error_content + " " + err_text,
        }
    )


@app.post("/auslegung-2", response_class=HTMLResponse)
async def auslegung_2(request: Request) -> None:
    form_data = await request.form()
    form_data_dict = dict(form_data)

    err_text = ""
    output_content = ""
    error_content = ""
    stderr_data = None
    stdout_data = None

    try:
        tmp_stdout_filename = "/tmp/" + str(uuid.uuid4()) + ".out.txt"
        tmp_stderr_filename = "/tmp/" + str(uuid.uuid4()) + ".err.txt"
        my_env = os.environ.copy()
        my_env['SCRIPT_DIR'] = os.getenv('SCRIPT_DIR')
        with open(tmp_stdout_filename, 'w') as stdout_file_object, open(tmp_stderr_filename, 'w') as stderr_file_object:
            process = subprocess.run(
                [Path(os.getenv('SCRIPT_DIR')) / Path(os.getenv('AUS_FORM2_SCRIPT')), json.dumps(form_data_dict),],
                stdout=stdout_file_object,
                stderr=stderr_file_object,
                encoding="utf-8",
                text=True,
                check=False,
                env=my_env
            )

        with open(tmp_stdout_filename, "r") as tmp_file:
            stdout_data = tmp_file.read()
        os.unlink(tmp_stdout_filename)

        with open(tmp_stderr_filename, "r") as tmp_file:
            stderr_data = tmp_file.read()
        os.unlink(tmp_stderr_filename)

        if stderr_data:
            logger.error(json.dumps({'error_message': stderr_data.replace("\n", " ")}, ensure_ascii=False))

        try:
            json_xdata = json.loads(stdout_data)
            try:
                output_content = base64.b64decode(json_xdata.get('output_content')).decode('utf-8')
                error_content = base64.b64decode(json_xdata.get('error_content')).decode('utf-8')
            except Exception as err:
                error_content = str(err)
        except json.decoder.JSONDecodeError as err:
            error_content = str(err)
    except subprocess.CalledProcessError as ee:
        err_text = "Error executing script"
    except FileNotFoundError:
        err_text = "Script not found. Ensure it's executable and in the correct path."

    return templates.TemplateResponse(
        "aus_page2.html", {
            "request": request,
            "output_content": output_content,
            "stderr_content": stderr_data,
            "error_content": error_content + " " + err_text,
        }
    )


@app.post("/process-form", response_class=HTMLResponse)
async def process_form(request: Request) -> None:
    form_data = await request.form()
    form_data_dict = dict(form_data)

    err_text = ""
    output_content = ""
    error_content = ""
    stderr_data = None
    stdout_data = None

    try:
        tmp_stdout_filename = "/tmp/" + str(uuid.uuid4()) + ".out.txt"
        tmp_stderr_filename = "/tmp/" + str(uuid.uuid4()) + ".err.txt"
        my_env = os.environ.copy()
        my_env['SCRIPT_DIR'] = os.getenv('SCRIPT_DIR')
        with open(tmp_stdout_filename, 'w') as stdout_file_object, open(tmp_stderr_filename, 'w') as stderr_file_object:
            process = subprocess.run(
                [Path(os.getenv('SCRIPT_DIR')) / Path(os.getenv('FORM_SCRIPT')), json.dumps(form_data_dict),],
                stdout=stdout_file_object,
                stderr=stderr_file_object,
                encoding="utf-8",
                text=True,
                check=False,
                env=my_env
            )

        with open(tmp_stdout_filename, "r") as tmp_file:
            stdout_data = tmp_file.read()
        os.unlink(tmp_stdout_filename)

        with open(tmp_stderr_filename, "r") as tmp_file:
            stderr_data = tmp_file.read()
        os.unlink(tmp_stderr_filename)

        if stderr_data:
            logger.error(json.dumps({'error_message': stderr_data.replace("\n", " ")}, ensure_ascii=False))

        try:
            json_xdata = json.loads(stdout_data)
            try:
                output_content = base64.b64decode(json_xdata.get('output_content')).decode('utf-8')
                error_content = base64.b64decode(json_xdata.get('error_content')).decode('utf-8')
            except Exception as err:
                error_content = str(err)
        except json.decoder.JSONDecodeError as err:
            error_content = str(err)
    except subprocess.CalledProcessError as ee:
        err_text = "Error executing script"
    except FileNotFoundError:
        err_text = "Script not found. Ensure it's executable and in the correct path."

    return templates.TemplateResponse(
        "form_result.html", {
            "request": request,
            "output_content": output_content,
            "stderr_content": stderr_data,
            "error_content": error_content + " " + err_text,
        }
    )


@app.get("/aus_page1", response_class=HTMLResponse)
async def root(request: Request) -> None:
    xdata = None
    err_text = ""
    output_content = ""
    error_content = ""
    stderr_data = None
    stdout_data = None

    tmp_stdout_filename = "/tmp/" + str(uuid.uuid4()) + ".out.txt"
    tmp_stderr_filename = "/tmp/" + str(uuid.uuid4()) + ".err.txt"
    my_env = os.environ.copy()
    my_env['SCRIPT_DIR'] = os.getenv('SCRIPT_DIR')
    with open(tmp_stdout_filename, 'w') as stdout_file_object, open(tmp_stderr_filename, 'w') as stderr_file_object:
        process = subprocess.run(
            [Path(os.getenv('SCRIPT_DIR')) / Path(os.getenv('AUS_SCRIPT')),],
            stdout=stdout_file_object,
            stderr=stderr_file_object,
            encoding="utf-8",
            text=True,
            check=False,
            env=my_env
        )
    with open(tmp_stdout_filename, "r") as tmp_file:
        stdout_data = tmp_file.read()
    os.unlink(tmp_stdout_filename)

    with open(tmp_stderr_filename, "r") as tmp_file:
        stderr_data = tmp_file.read()
        os.unlink(tmp_stderr_filename)

    if stderr_data:
        logger.error(json.dumps({'error_message': stderr_data.replace("\n", " ")}, ensure_ascii=False))

    try:
        json_xdata = json.loads(stdout_data)
        try:
            output_content = base64.b64decode(json_xdata.get('output_content')).decode('utf-8')
            error_content = base64.b64decode(json_xdata.get('error_content')).decode('utf-8')
        except Exception as err:
            error_content = str(err)
    except json.decoder.JSONDecodeError as err:
        error_content = str(err)
    except subprocess.CalledProcessError as ee:
        err_text = "Error executing script"
    except FileNotFoundError:
        err_text = "Script not found. Ensure it's executable and in the correct path."

    return templates.TemplateResponse(
        "aus_page1.html", {
            "request": request,
            "output_content": output_content,
            "stderr_content": stderr_data,
            "error_content": error_content + " " + err_text,
        }
    )


@app.get("/", response_class=HTMLResponse)
async def root(request: Request, filter_name: str = None) -> None:
    xdata = None
    err_text = ""
    output_content = ""
    error_content = ""
    form_content = ""
    stderr_data = None
    stdout_data = None

    if filter_name:
        try:
            tmp_stdout_filename = "/tmp/" + str(uuid.uuid4()) + ".out.txt"
            tmp_stderr_filename = "/tmp/" + str(uuid.uuid4()) + ".err.txt"
            my_env = os.environ.copy()
            my_env['SCRIPT_DIR'] = os.getenv('SCRIPT_DIR')
            with open(tmp_stdout_filename, 'w') as stdout_file_object, open(tmp_stderr_filename, 'w') as stderr_file_object:
                process = subprocess.run(
                    [Path(os.getenv('SCRIPT_DIR')) / Path(os.getenv('MAIN_SCRIPT')), filter_name,],
                    stdout=stdout_file_object,
                    stderr=stderr_file_object,
                    encoding="utf-8",
                    text=True,
                    check=False,
                    env=my_env
                )
            with open(tmp_stdout_filename, "r") as tmp_file:
                stdout_data = tmp_file.read()
            os.unlink(tmp_stdout_filename)

            with open(tmp_stderr_filename, "r") as tmp_file:
                stderr_data = tmp_file.read()
            os.unlink(tmp_stderr_filename)

            if stderr_data:
                logger.error(json.dumps({'error_message': stderr_data.replace("\n", " ")}, ensure_ascii=False))

            try:
                json_xdata = json.loads(stdout_data)
                try:
                    output_content = base64.b64decode(json_xdata.get('output_content')).decode('utf-8')
                    error_content = base64.b64decode(json_xdata.get('error_content')).decode('utf-8')
                    form_content = base64.b64decode(json_xdata.get('form_content')).decode('utf-8')
                except Exception as err:
                    error_content = str(err)
            except json.decoder.JSONDecodeError as err:
                error_content = str(err)
        except subprocess.CalledProcessError as ee:
            err_text = "Error executing script"
        except FileNotFoundError:
            err_text = "Script not found. Ensure it's executable and in the correct path."

    print("stderr_data =", stderr_data)

    return templates.TemplateResponse(
        "index.html", {
            "request": request,
            "output_content": output_content,
            "stderr_content": stderr_data,
            "error_content": error_content + " " + err_text,
            "form_content": form_content,
        }
    )


@app.get("/api/swagger", include_in_schema=False)
async def custom_swagger_ui_html():
    return get_swagger_ui_html(
        openapi_url=app.openapi_url,
        title=app.title + " - Swagger UI",
        oauth2_redirect_url=app.swagger_ui_oauth2_redirect_url,
        swagger_js_url="/static/swagger-ui-bundle.js",
        swagger_css_url="/static/swagger-ui.css",
    )


@app.get(app.swagger_ui_oauth2_redirect_url, include_in_schema=False)
async def swagger_ui_redirect():
    return get_swagger_ui_oauth2_redirect_html()


@app.exception_handler(Exception)
def exception_handler(request, exc):
    json_resp = get_default_error_response()
    return json_resp


def get_default_error_response(
    status_code=503, message="Unavailable."
):  # noqa: E501
    return JSONResponse(
        status_code=status_code,
        content={"status_code": status_code, "message": message},
    )
