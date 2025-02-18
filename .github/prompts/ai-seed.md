To increase the chances of getting exactly what you want on the first try, you can add structured data and metadata to the prompt files. Structured data is easier for AI models like GitHub Copilot to understand and process. Here are some suggestions:

1. **Add Metadata**: Include metadata at the beginning of the prompt to provide context and specific instructions. This can help the AI understand the requirements better.

2. **Use Structured Data**: Break down the prompt into smaller, well-defined sections. This makes it easier for the AI to parse and generate the desired output.

3. **Provide Examples**: Include examples of the desired output format. This helps the AI understand the expected structure and content.

4. **Be Specific**: Clearly specify the requirements and constraints. The more detailed and specific the instructions, the better the AI can generate the correct output.

Here is an example of a structured prompt with metadata:

# Metadata
- Purpose: Generate Terraform code for AWS resources
- Author: Your Name
- Date: YYYY-MM-DD

# Instructions
Please generate Terraform code to create an AWS S3 bucket with the following attributes:
- Bucket name: my-bucket
- Region: us-west-2
- Versioning enabled
- Public access blocked

# Example Output