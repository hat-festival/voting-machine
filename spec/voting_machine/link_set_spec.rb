module VotingMachine
  describe LinkSet do
    BASE_URL = 'http://example.org:9292/chain'
    context 'link array' do
      it 'generates the array for the first page' do
        pagy = double
        {
          last: 3, next: 2, page: 1, pages: 3, prev: nil
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        expect(LinkSet.collection BASE_URL, pagy).to eq [
          "<http://example.org:9292/chain?page=3>; rel='last'",
          "<http://example.org:9292/chain?page=2>; rel='next'"
        ]
      end

      it 'generates the array for the last page' do
        pagy = double
        {
          last: 3, next: nil, page: 3, pages: 3, prev: 2
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        expect(LinkSet.collection BASE_URL, pagy).to eq [
          "<http://example.org:9292/chain>; rel='first'",
          "<http://example.org:9292/chain?page=2>; rel='prev'"
        ]
      end

      it 'generates the array for a middle page' do
        pagy = double
        {
          last: 3, next: 3, page: 2, pages: 3, prev: 1
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        expect(LinkSet.collection BASE_URL, pagy).to eq [
          "<http://example.org:9292/chain>; rel='first'",
          "<http://example.org:9292/chain?page=3>; rel='last'",
          "<http://example.org:9292/chain?page=3>; rel='next'",
          "<http://example.org:9292/chain?page=1>; rel='prev'"
        ]
      end

      it 'generates the array for an out-of-bounds page' do
        pagy = double
        {
          last: 3, page: 15, pages: 3, prev: 3
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        expect(LinkSet.collection BASE_URL, pagy).to eq [
          "<http://example.org:9292/chain>; rel='first'",
          "<http://example.org:9292/chain?page=3>; rel='last'",
          "<http://example.org:9292/chain?page=3>; rel='prev'"
        ]
      end
    end

    context 'with additional query-strings' do
      it 'accepts additional query-string values' do
        pagy = double
        {
          last: 3, next: 3, page: 2, pages: 3, prev: 1
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        qh = {
          per_page: 10,
          eggs: 19
        }

        expect(LinkSet.collection BASE_URL, pagy, query_hash: qh).to eq [
          "<http://example.org:9292/chain?eggs=19&per_page=10>; rel='first'",
          "<http://example.org:9292/chain?eggs=19&page=3&per_page=10>; rel='last'",
          "<http://example.org:9292/chain?eggs=19&page=3&per_page=10>; rel='next'",
          "<http://example.org:9292/chain?eggs=19&page=1&per_page=10>; rel='prev'"
        ]
      end

      it 'accepts additional query-string values for an out-of-bounds page' do
        pagy = double
        {
          last: 3, page: 15, pages: 3, prev: 3
        }.each_pair do |method, value|
          allow(pagy).to receive(method).and_return value
        end

        expect(LinkSet.collection BASE_URL,
                                      pagy,
                                      query_hash: {per_page: 10}).to eq [
          "<http://example.org:9292/chain?per_page=10>; rel='first'",
          "<http://example.org:9292/chain?page=3&per_page=10>; rel='last'",
          "<http://example.org:9292/chain?page=3&per_page=10>; rel='prev'"
        ]
      end
    end
  end
end
