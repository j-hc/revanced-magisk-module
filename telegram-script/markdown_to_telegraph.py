from telegraph import Telegraph
from gh_md_to_html import core_converter
import re

class MarkdownToTelegraph:
    def __init__(self, short_name: str, author_name: str, author_url: str) -> None:
        self.short_name = short_name
        self.author_name = author_name
        self.author_url = author_url
        self.telegraph = Telegraph()
        self.telegraph.create_account(short_name=self.short_name, author_name=self.author_name, author_url=self.author_url)
    
    def filter_html_tags(self, html_string: str) -> str:
        # Replace h1 tags with h3 tags 
        html_string = re.sub(r"<h1.*?>", "<h3>", html_string)
        html_string = re.sub(r"</h1>", "</h3>", html_string)
        # Replace h2 tags with h3 tags 
        html_string = re.sub(r"<h2.*?>", "<h3>", html_string)
        html_string = re.sub(r"</h2>", "</h3>", html_string)
        # Replace span tags with p tags using regex
        html_string = re.sub(r"<span.*?>", "<p>", html_string)
        html_string = re.sub(r"</span>", "</p>", html_string)
        return html_string

    def convert_file(self, markdown_file: str) -> str:
        markdown_string = open(markdown_file, "r").read()
        html_string = core_converter.markdown(markdown_string)
        html_string = self.filter_html_tags(html_string)
        return html_string
    
    def convert_string(self, markdown_string: str) -> str:
        html_string = core_converter.markdown(markdown_string)
        html_string = self.filter_html_tags(html_string)
        return html_string
    
    def create_page(self, title: str, html_content: str) -> str:
        response = self.telegraph.create_page(
            title,
            html_content=html_content,
            author_name=self.author_name,
            author_url=self.author_url
        )
        return response['url']
    
    def create_page_from_file(self, title: str, markdown_file: str) -> str:
        html_content = self.convert_file(markdown_file)
        return self.create_page(title, html_content)
    
    def create_page_from_string(self, title: str, markdown_string: str) -> str:
        html_string = self.convert_string(markdown_string)
        return self.create_page(title, html_content=html_string)
