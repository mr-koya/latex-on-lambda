import os
import subprocess
import json

def lambda_handler(event, context):
    tex_file_path = "/var/task/templates/example_template.tex"
    output_dir = "/var/task/output"

    try:
        result = subprocess.run(
            ["/bin/bash", "/var/task/compile_tex.sh", tex_file_path, output_dir],
            check=True,
            capture_output=True,
            text=True
        )
        pdf_file_path = os.path.join(output_dir, "example_template.pdf")
        if os.path.exists(pdf_file_path):
            return {
                'statusCode': 200,
                'body': json.dumps('PDF generated successfully.')
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps('PDF generation failed.')
            }
    except subprocess.CalledProcessError as e:
        return {
            'statusCode': 500,
            'body': json.dumps('LaTeX compilation failed. See logs for details.')
        }

if __name__ == "__main__":
    event = {}
    context = None
    print(lambda_handler(event, context))

