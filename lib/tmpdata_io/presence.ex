defmodule TmpDataIO.Presence do
  use Phoenix.Presence, otp_app: :tmpdata_io, pubsub_server: TmpDataIO.PubSub

end
