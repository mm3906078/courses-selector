defmodule CoursesWeb.Router do
  use CoursesWeb, :router

  import CoursesWeb.AuthController

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {CoursesWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: CoursesWeb.ApiSpec)
  end

  pipeline :require_auth do
    plug :fetch_current_user
  end

  pipeline :require_admin do
    plug :fetch_current_user
    plug :admin_only
  end

  scope "/api/v1", CoursesWeb do
    pipe_through(:api)

    post("/login", AuthController, :login)
    post("/register", AuthController, :register)
    get("/list", AuthController, :list)
  end

  scope "/api/v1", CoursesWeb do
    pipe_through([:api, :require_auth])

    get("/courses", CourseController, :index)
    post("/courses/create", CourseController, :create)
    delete("/courses/remove/:id", CourseController, :remove)
  end

  scope "/api/v1", CoursesWeb do
    pipe_through([:api, :require_auth])

    post("/user/enroll/:id", UserController, :enroll)
    post("/user/unenroll/:id", UserController, :unenroll)
    get("/user/courses", UserController, :courses)
  end

  scope "/" do
    pipe_through(:browser)
    get("/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi")
  end

  scope "/api" do
    pipe_through(:api)

    get("/openapi", OpenApiSpex.Plug.RenderSpec, [])
  end
end
