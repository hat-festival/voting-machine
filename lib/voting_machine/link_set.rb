module VotingMachine
  module LinkSet
    def self.collection base_url, pagy, query_hash: {}
      rels = case pagy.page
      when (pagy.last + 1)..(1.0/0.0) # i.e. we're anywhere past the last page
        out_of_bounds = true # this is a weird special case
        [:first, :last, :prev]
      when 1
        [:last, :next]
      when pagy.last
        [:first, :prev]
      else
        [:first, :last, :next, :prev]
      end

      coll = rels.map { |rel| Element.new base_url, rel, pagy, query_hash }

      coll.last.out_of_bounds! if out_of_bounds

      coll.map { |e| e.to_s }
    end

    def self.links base_url, pagy, query_hash: {}
      collection(base_url, pagy, query_hash: query_hash).join ', '
    end

    class Element
      attr_writer :rel, :query_hash

      def initialize base_url, rel, pagy, query_hash
        @base_url = base_url
        @rel = rel
        @pagy = pagy
        compose_query_hash query_hash
      end

      def out_of_bounds!
        @rel = :prev
        @query_hash[:page] = @pagy.last
      end

      def compose_query_hash hash
        hash.delete 'page'
        @query_hash = @rel == :first ? {} : {page: @pagy.send(@rel)}
        @query_hash.merge! hash
        @query_hash = nil if @query_hash == {}
      end

      def query_string
        if @query_hash
          return "?#{@query_hash.to_a.map { |e| "#{e[0]}=#{e[1]}" }.sort.join('&')}"
        end
      end

      def to_s
        "<#{@base_url}#{query_string}>; rel='#{@rel}'"
      end
    end
  end
end
