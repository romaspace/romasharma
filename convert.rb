#!/usr/bin/env ruby

require 'active_support/core_ext/hash/conversions'
require 'date'

def slug(title)
  _slug = title.gsub(/\W+/,'-')
  _slug.sub!(/^-/,'')
  _slug.sub!(/-$/,'')
  _slug
end

def post_file_name(pub_date,title)
  "_posts/" + pub_date + "-" + slug(title) + ".markdown"
end

xmlData = File.read('roma.xml')

hash = Hash.from_xml(xmlData)

categories = []
hash["rss"]["channel"]["wp_category"].each do |cat|
  _cat = cat["wp_cat_name"]
  categories << _cat
  _cat_slug = _cat.downcase.gsub(/\W+/,'-')
  cat_filename = "category/#{_cat_slug}.markdown"
  f = File.open(cat_filename,"w")
  f.write <<EOF
---
layout: category
category: #{_cat}
title: Category - #{_cat}
---
EOF
  f.close
end

hash["rss"]["channel"]["item"].each do |post|
  if post["wp_post_type"] == "post"
    pub_date_time = post["wp_post_date"]
    pub_date = pub_date_time.split(" ")[0]
    permalink = post["link"].sub(/http.*\.com/,'')
    content = post["content_encoded"]
    content.gsub!(/\[\/caption\]/,"</div>")
    content.gsub!(/\[caption.*\]/,"<div class='post-image'>")
    content.gsub!(/http:\/\/romaspacenew\.files\.wordpress\.com/,'')
    title = post["title"]
    all_tags = post["category"].respond_to?("map") ? post["category"] : [post["category"]]
    post_categories = []
    post_tags = []
    all_tags.each do |tag|
      if categories.index(tag)
        post_categories << tag
      else
        post_tags << tag
      end
    end
    post_categories.uniq!
    post_tags.uniq!

    if content =~ /img .*src="(\S*)"/
      image_path = $~[1]
    end
    filename = post_file_name(pub_date,title)
    f = File.open(filename,"w")
    f.write <<EOF
--- 
permalink: #{permalink}
layout: post
title: #{title}
image: #{image_path}
published: true
author: Roma Sharma
categories: 
#{post_categories.map{|a| "- "+a}.join("\n")}
tags:
#{post_tags.map{|a| "- "+a}.join("\n")}
---
#{content}
EOF
    f.close
  end
end

