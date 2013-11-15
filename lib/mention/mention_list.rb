module Mention
  class MentionList
    include Virtus.value_object(strict: true)

    values do
      attribute :mentions, Array[Mention]
      attribute :_links, Hash
    end

    extend Forwardable
    def_delegator :mentions, :each
    include Enumerable
  end
end
