#!/usr/bin/env ruby

require 'active_support/core_ext/hash/conversions'
require 'date'
require 'pathname'

def convert_img(img,dim)
  img_src = Pathname.new img.sub(/^\//,'').sub(/\?.*?$/,'')
  img_dst = img_src.sub(img_src.extname,"_"+dim+img_src.extname)
  `convert #{img_src.realpath} -trim -resize #{dim}^ -gravity Center -crop #{dim}+0+0  +repage #{img_dst}`
  return "/#{img_dst}" 
end

def convert_230x150(img)
  convert_img(img,"230x150")
end

def convert_thumbnail(img)
  convert_img(img,"200x200")
end

def slug(title)
  _slug = title.gsub(/\W+/,'-')
  _slug.sub!(/^-/,'')
  _slug.sub!(/-$/,'')
  _slug
end

def post_file_name(pub_date,title)
  "_posts/" + pub_date + "-" + slug(title) + ".markdown"
end

puts "Reading roma.xml"
xmlData = File.read('roma.xml')

puts "Parsing XML file"
hash = Hash.from_xml(xmlData)

puts "Extracting categories"
categories = []
hash["rss"]["channel"]["wp_category"].each do |cat|
  _cat = cat["wp_cat_name"]
  categories << _cat
end

puts "Processing Posts"
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

    if image_path and image_path =~ /^\//
      image_230x150_path = convert_230x150(image_path)
      image_thumbnail_path = convert_thumbnail(image_path)
    end

    image_path = "/images/default.jpg" unless image_path
    image_230x150_path = "/images/default_230x150.jpg" unless image_230x150_path
    image_thumbnail_path = "/images/default_thumbnail.jpg" unless image_thumbnail_path

    filename = post_file_name(pub_date,title)
    f = File.open(filename,"w")
    f.write <<EOF
--- 
permalink: #{permalink}
layout: post
title: #{title}
image: #{image_path}
image_230x150: #{image_230x150_path}
image_thumbnail: #{image_thumbnail_path}
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

puts "Done."
