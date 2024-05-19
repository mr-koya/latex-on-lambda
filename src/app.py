import subprocess
import json

def handler(event, context):
    try:
        # Execute the LaTeX compilation script
        subprocess.run(["./compile_tex.sh"], check=True)
        return {
            'statusCode': 200,
            'body': json.dumps('LaTeX document compiled successfully')
        }
    except subprocess.CalledProcessError as e:
        return {
            'statusCode': 500,
            'body': json.dumps('Error during LaTeX compilation')
        }

