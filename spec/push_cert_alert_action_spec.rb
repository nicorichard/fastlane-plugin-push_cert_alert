describe Fastlane::Actions::PushCertAlertAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The push_cert_alert plugin is working!")

      Fastlane::Actions::PushCertAlertAction.run(nil)
    end
  end
end
