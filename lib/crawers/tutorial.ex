defmodule Homebase do
    @behaviour Crawly.Spider
  
    # @impl Crawly.Spider
    # def base_url(), do: "https://www.homebase.co.uk"
  
    @impl Crawly.Spider
    def init() do
      [
        start_urls: [
          "https://www.homebase.co.uk/our-range/tools"
        ]
      ]
    end
    #Crawly.Engine.start_spider(Homebase)
  
    @impl Crawly.Spider
    def parse_item(response) do
      IO.inspect(response)
      %Crawly.ParsedItem{:items => [], :requests => []}
    end
  end
  