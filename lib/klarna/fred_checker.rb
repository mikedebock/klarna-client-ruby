if defined? SystemReadiness::BaseChecker
  class Klarna::FredChecker < SystemReadiness::BaseChecker
    def check
      Klarna::Client.ping
    end
  end
end
