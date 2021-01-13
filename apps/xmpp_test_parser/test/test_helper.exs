# This code is used, because testing is done without starting the supervision tree.
# (mix test --no-start)
Application.load(:xmpp_test_parser)
for app <- Application.spec(:xmpp_test_parser, :applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
