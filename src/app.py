import os
import subprocess

def lambda_handler(event, context):
    # Path to the example LaTeX file
    tex_file_path = "/var/task/templates/example_template.tex"
    output_dir = "/var/task/output"

    # Compile the LaTeX file
    compile_tex(tex_file_path, output_dir)

    # Read the generated PDF
    pdf_file_path = os.path.join(output_dir, "example_template.pdf")
    with open(pdf_file_path, 'rb') as f:
        pdf_data = f.read()

    # Return the PDF data as a base64 encoded string
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/pdf'},
        'body': pdf_data.encode('base64')
    }

def compile_tex(tex_file_path, output_dir):
    subprocess.run(["/var/task/compile_tex.sh", tex_file_path, output_dir], check=True)

