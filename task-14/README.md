# 🚀 Event-Driven Automation using AWS S3, Lambda & CloudWatch

## 📌 Overview

This project demonstrates a **serverless event-driven architecture** using AWS services.

When a file is uploaded to an Amazon S3 bucket, an AWS Lambda function is automatically triggered. The function processes the event and logs details to Amazon CloudWatch.

✅ No server management
✅ No manual execution
✅ Fully automated workflow

---

## 🧠 What is AWS Lambda?

AWS Lambda is a **serverless compute service** that allows you to run code without provisioning or managing servers.

* Write your code
* Upload it to AWS
* AWS executes it automatically on events

---

## ⚙️ Architecture

```
S3 (File Upload) → Lambda Function → CloudWatch Logs
```

---

## 🛠️ AWS Services Used

| Service    | Purpose                                   |
| ---------- | ----------------------------------------- |
| Amazon S3  | Stores uploaded files and triggers events |
| AWS Lambda | Executes code in response to events       |
| IAM        | Manages permissions and access control    |
| CloudWatch | Stores logs and monitors execution        |

---

## 📂 Project Setup

### Step 1: Create Lambda Function

1. Go to **AWS Console → Lambda**
2. Click **Create Function**
3. Choose **Author from scratch**
4. Configure:

   * **Function Name:** `s3-lambda-event-driven`
   * **Runtime:** Python 3.x (or Node.js)
5. Under Permissions:

   * Select **Create a new role with basic Lambda permissions**

#### Attach IAM Policies:

* `AWSLambdaBasicExecutionRole` (for CloudWatch logging)
* `AmazonS3ReadOnlyAccess` (for reading S3 event data)

---

### Step 2: Add Lambda Code (Python)

```python
import json

def lambda_handler(event, context):
    print("=== FULL EVENT PAYLOAD ===")
    print(json.dumps(event, indent=2))

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        size = record['s3']['object']['size']

        print(f"File uploaded: {key} ({size} bytes) in bucket {bucket}")

    return {
        "statusCode": 200,
        "body": "File processed successfully"
    }
```

---

### Step 3: Configure S3 Trigger

1. Go to **S3 → Create Bucket**
2. Open your bucket → **Properties**
3. Scroll to **Event notifications**
4. Click **Create event notification**

#### Configuration:

* **Name:** `trigger-lambda-on-upload`
* **Event type:** All object create events
* **Destination:** Lambda function → `s3-lambda-event-driven`

Click **Save changes**

---

### Step 4: Upload a File

1. Open your S3 bucket
2. Click **Upload**
3. Select a file (e.g., `test.txt`)
4. Upload it

---

### Step 5: Verify in CloudWatch

1. Go to **CloudWatch → Logs → Log groups**
2. Open:

   ```
   /aws/lambda/s3-lambda-event-driven
   ```
3. Open the latest log stream

---

## ✅ Sample Output

```
=== FULL EVENT PAYLOAD ===
{
  "Records": [
    {
      "eventSource": "aws:s3",
      "eventName": "ObjectCreated:Put"
    }
  ]
}

File uploaded: test.txt (524 bytes) in bucket my-demo-bucket
```

---

## 🎯 Key Features

* Serverless architecture
* Event-driven automation
* Real-time processing
* Scalable and cost-efficient

---

## 📘 Concepts Covered

* AWS Lambda
* S3 Event Notifications
* IAM Roles & Policies
* CloudWatch Logging
* Event-Driven Architecture

---

