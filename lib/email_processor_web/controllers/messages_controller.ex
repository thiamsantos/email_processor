defmodule EmailProcessorWeb.MessagesController do
  use EmailProcessorWeb, :controller

  def create(conn, %{"queue_name" => queue_name, "email" => email, "subject" => subject, "message" => message}) do
    email_message = %{queue_name: queue_name, email: email, subject: subject, message: message}
    EmailProcessor.Enqueuer.enqueue(email_message)

    conn
    |> put_status(:ok)
    |> json(email_message)
  end

  def create(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{detail: "Invalid email message"})
  end
end
