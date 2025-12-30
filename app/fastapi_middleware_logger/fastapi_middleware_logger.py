from fastapi import FastAPI, Response, Request
from starlette.background import BackgroundTask
from starlette.types import Message
import logging
import json
import base64
import httpx
import traceback


async def default_logger(**kwargs):
    """Logs all the available information for a normal response"""
    # logging.info(json.dumps(kwargs, indent=4))
    await external_logger(kwargs)
    logging.info(json.dumps(kwargs, ensure_ascii=False))


def default_error_logger(**kwargs):
    """Logs all the available information for a response with error"""
    # logging.info(json.dumps(kwargs, indent=4))
    logging.info(json.dumps(kwargs, ensure_ascii=False))


async def set_body(request: Request, body: bytes):
    """Utility function to recreate the body of a request"""

    async def receive() -> Message:
        return {"type": "http.request", "body": body}

    request._receive = receive


def disable_loggers():
    """Disable UVICORN and FASTAPI loggers by setting them to CRITICAL levels"""
    uvicorn_error = logging.getLogger("uvicorn.error")
    uvicorn_error.setLevel(level=logging.CRITICAL)
    uvicorn_access = logging.getLogger("uvicorn.access")
    uvicorn_access.setLevel(level=logging.CRITICAL)
    uvicorn_access = logging.getLogger("uvicorn")
    uvicorn_access.setLevel(level=logging.CRITICAL)
    fastapi_logger = logging.getLogger("fastapi")
    fastapi_logger.setLevel(level=logging.CRITICAL)


def add_custom_logger(
    app: FastAPI,
    custom_logger: callable = default_logger,
    custom_error_logger: callable = default_error_logger,
    disable_uvicorn_logging: bool = True,
    external_logger_uri: str = None
) -> FastAPI:
    """Function to add custom loggers to a FastAPI application

    Args:
        app (FastAPI): a FastAPI application
        custom_logger (callable, optional): function used to print logs when working normally.
            Defaults to `default_logger`.
        custom_error_logger (callable, optional): funtion used to print logs when an error occurs.
            Defaults to `default_error_logger`.
        disable_uvicorn_logging (bool, optional): if True, usual uvicorn and FastAPI logs are inhibited.
            Defaults to True.


    Returns:
        FastAPI: FastAPI app with the custom loggers
    """
    if disable_uvicorn_logging:
        disable_loggers()

    @app.middleware("http")
    async def middleware_logger(request: Request, call_next):
        request_body = await request.body()
        await set_body(request, request_body)
        try:
            response = await call_next(request)
        except Exception as exc:
            custom_error_logger(
                **{
                    "request_body": request_body.decode("utf-8"),
                    "request_client_host": request.client.host,
                    "request_method": request.method,
                    "request_url": str(request.url),
                    # "request_headers": dict(request.headers),
                    "request_query_params": dict(request.query_params),
                    "error_message": str(exc) + traceback.format_exc(),
                },
            )
            raise exc

        response_body = b""
        async for chunk in response.body_iterator:
            response_body += chunk

        username = None
        if "Authorization" in request.headers:
            try:
                auth = request.headers["Authorization"]
                scheme, credentials = auth.split()
                decoded = base64.b64decode(credentials).decode("ascii").split(':')
                username = decoded[0]
            except:
                pass

        task = None
        # if request.headers.get("Content-type") == "application/json":
        if "/api" in str(request.url):
            task = BackgroundTask(
                custom_logger,
                **{
                    "logger_uri": external_logger_uri,
                    "username": username,
                    "request_client_host": request.client.host,
                    "request_method": request.method,
                    "request_uri": str(request.url),
                    "request_body": request_body.decode("utf-8"),
                    # "request_headers": dict(request.headers),
                    "request_query_params": str(dict(request.query_params)),
                    "response_body": str(response_body.decode('utf-8')),
                    # "response_headers": dict(response.headers),
                    # "response_media_type": response.media_type,
                    "response_status_code": str(response.status_code),
                },
            )
            return Response(
                content=response_body,
                status_code=response.status_code,
                headers=dict(response.headers),
                media_type=response.media_type,
                background=task,
            )
        else:
            try:
                return Response(
                    content=response_body,
                    status_code=response.status_code,
                    headers=dict(response.headers),
                    media_type=response.media_type,
                )
            except Exception as e:
                print(str(e))
    return app


class FastAPIMiddleWareLogger(FastAPI):
    """Class that inherits from FastAPI and allows to add custom loggers"""

    def __init__(
        self,
        custom_logger: callable = default_logger,
        custom_error_logger: callable = default_error_logger,
        disable_uvicorn_logger: bool = True,
        *args,
        **kwargs,
    ):
        FastAPI.__init__(self, *args, **kwargs)
        add_custom_logger(
            self,
            custom_logger=custom_logger,
            custom_error_logger=custom_error_logger,
            disable_uvicorn_logging=disable_uvicorn_logger,
        )


async def external_logger(req_params) -> None:
    if req_params.get("logger_uri"):
        try:
            response = httpx.post(req_params["logger_uri"], json=req_params, headers={"Content-Type": "application/json"})
            response.raise_for_status()
        except httpx.RequestError as exc:
            print(f"Произошла ошибка при запросе: {exc.request.url!r}.")
        except httpx.HTTPStatusError as exc:
            print(f"Ошибочный код запроса: {exc.response.status_code} при выполнени запроса {exc.request.url!r}.")
