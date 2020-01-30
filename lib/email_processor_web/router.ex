defmodule EmailProcessorWeb.Router do
  use EmailProcessorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EmailProcessorWeb do
    pipe_through :api

    post "/messages", MessagesController, :create
  end
end
