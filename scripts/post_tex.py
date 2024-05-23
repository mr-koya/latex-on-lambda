import os
import base64
import requests
import json

def encode_file_to_base64(file_path):
    with open(file_path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

def main():
    tex_file_path = '../templates/example_template.tex'
    bib_file_path = '../templates/references.bib'
    url = "http://localhost:9000/2015-03-31/functions/function/invocations"

    tex_content = encode_file_to_base64(tex_file_path)
    bib_content = encode_file_to_base64(bib_file_path)

    payload = {
        "tex_content": tex_content,
        "bib_content": bib_content
    }

    headers = {
        "Content-Type": "application/json"
    }

    response = requests.post(url, data=json.dumps(payload), headers=headers)

    if response.status_code == 200:
        response_json = response.json()
        response_body = json.loads(response_json['body'])
        message = response_body.get('message', 'No message found')
        pdf_content = response_body.get('pdf_content', '')

        print("Message:", message)
        
        if pdf_content:
            os.makedirs('../output', exist_ok=True)
            pdf_data = base64.b64decode(pdf_content)
            with open('../output/example_template.pdf', 'wb') as pdf_file:
                pdf_file.write(pdf_data)
            print("PDF generated successfully and saved to output/example_template.pdf")
        else:
            print("PDF generation failed.")
    else:
        print(f"Failed to generate PDF. Status code: {response.status_code}")
        print("Response text:")
        print(response.text)

if __name__ == "__main__":
    main()

