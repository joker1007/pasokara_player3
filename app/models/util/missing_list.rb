# coding:utf-8
module Util
  class MissingList

    def self.create_rss
      remote_list = []
      remote_name_list = {}
      STDIN.readlines.each do |line|
        attrs = line.split(",")
        attrs[0].scan(/(sm\d+)/)
        remote_list << $1 if $1
        remote_name_list.merge!($1 => attrs[1]) if $1
      end


      pasokaras = PasokaraFile.find(:all, :select => "nico_name")
      exists = pasokaras.map {|p| p.nico_name}

      missings = remote_list - exists


      time_now = Time.now

      header = <<-EOL
      <?xml version="1.0" encoding="utf-8"?>
      <rss version="2.0"
           xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
          <title>ニコニコ動画(9)</title>
          <link>http://www.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%82%AB%E3%83%A9?sort=f</link>
          <atom:link rel="self" type="application/rss+xml" href="http://www.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%82%AB%E3%83%A9?page=1&amp;sort=f&amp;rss=2.0"/>
          <description>タグ「ニコカラ」が付けられた動画 (全 3,194 件)</description>
          <pubDate>#{time_now.to_s}</pubDate>
          <lastBuildDate>#{time_now.to_s}</lastBuildDate>
          <generator>ニコニコ動画(9)</generator>
          <language>ja</language>
          <copyright>(c) niwango, inc. All rights reserved.</copyright>
          <docs>http://blogs.law.harvard.edu/tech/rss</docs>

      EOL

      footer = <<-EOL
        </channel>
      </rss>
      EOL

      items = []
      missings.each do |nico_id|
        i = <<-EOL
          <item>
            <title>#{remote_name_list[nico_id]}</title>
            <link>http://www.nicovideo.jp/watch/#{nico_id}</link>
            <guid isPermaLink="false">tag:nicovideo.jp,#{time_now.strftime("%Y-%m-%d")}:/watch/#{nico_id}</guid>
            <pubDate>#{time_now.to_s}</pubDate>
            <description><![CDATA[
            ダミー
            ]]></description>
          </item>
        EOL
        items << i
      end

      puts header + "\n" + items.join("\n") + "\n" + footer
    end
  end
end
