defmodule CoursesWeb.AuthJSON do
  def render("error.json", %{reason: reason}) do
    %{error: reason}
  end

  def render("login.json", %{user: user, token: token}) do
    %{user: user, token: token}
  end

  def render("register.json", %{user: user}) do
    %{user: user}
  end

  def render("list.json", %{users: users}) do
    %{users: users}
  end

  def render("remove.json", %{user: user}) do
    %{user: user}
  end
end
