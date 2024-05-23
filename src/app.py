import os
import subprocess
import json
import base64
import logging

logging.basicConfig(level=logging.INFO)

def save_file(encoded_content, file_path):
    try:
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'wb') as f:
            f.write(base64.b64decode(encoded_content))
    except Exception as e:
        logging.error(f"Failed to save file {file_path}: {str(e)}")
        raise

def lambda_handler(event, context):
    logging.info("Event received by lambda_handler")
    tex_content = event.get('tex_content')
    bib_content = event.get('bib_content')
    
    if not tex_content or not bib_content:
        logging.error("tex_content and bib_content must be provided.")
        return {
            'statusCode': 400,
            'body': json.dumps('tex_content and bib_content must be provided.')
        }
    
    tex_file_path = "/var/task/templates/example_template.tex"
    bib_file_path = "/var/task/templates/references.bib"
    output_dir = "/var/task/output"
    
    os.makedirs(output_dir, exist_ok=True)
    
    logging.info("Saving tex and bib files")
    save_file(tex_content, tex_file_path)
    save_file(bib_content, bib_file_path)
    
    try:
        logging.info("Running LaTeX compilation script")
        result = subprocess.run(
            ["/bin/bash", "/var/task/compile_tex.sh", tex_file_path, output_dir],
            check=True,
            capture_output=True,
            text=True
        )
        logging.info("LaTeX compilation script completed")
        logging.info(f"stdout: {result.stdout}")
        logging.info(f"stderr: {result.stderr}")

        pdf_file_path = os.path.join(output_dir, "example_template.pdf")
        logging.info(f"Checking if PDF file exists at {pdf_file_path}")
        if os.path.exists(pdf_file_path):
            logging.info(f"PDF file found at {pdf_file_path}, reading file")
            with open(pdf_file_path, 'rb') as pdf_file:
                pdf_base64 = base64.b64encode(pdf_file.read()).decode('utf-8')
            logging.info("PDF generated successfully")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'PDF generated successfully.',
                    'pdf_content': pdf_base64
                })
            }
        else:
            logging.error("PDF generation failed, file not found.")
            return {
                'statusCode': 500,
                'body': json.dumps('PDF generation failed, file not found.')
            }
    except subprocess.CalledProcessError as e:
        logging.error(f"LaTeX compilation failed: {e}")
        logging.error(f"stdout: {e.stdout}")
        logging.error(f"stderr: {e.stderr}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'LaTeX compilation failed. See logs for details. {e}')
        }

if __name__ == "__main__":
    event = {
        "tex_content": "base64-encoded-tex-content",
        "bib_content": "base64-encoded-bib-content"
    }
    context = None
    print(lambda_handler(event, context))

