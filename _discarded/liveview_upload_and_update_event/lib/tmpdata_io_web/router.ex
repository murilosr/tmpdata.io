scope "/lview", TmpDataIOWeb do
  pipe_through :browser

  live "/:page_id/", PublicContentPage
end
