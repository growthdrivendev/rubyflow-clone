require 'rails_helper'

describe Posts::FindQuery do
  describe '.call' do
    it 'returns post' do
      post = create(:post)

      expect(described_class.call(post.id)).to eq(post)
    end
  end
end
