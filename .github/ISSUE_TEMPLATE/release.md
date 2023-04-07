---
name: 🚀 New Release
about: Release a new version of the product.
title: "🚀 Release vX.X.X"
labels: "release"
---

## Steps to release the new product

- [ ] Log in to AWS
- [ ] Assume the Marketplace account
- [ ] Open new tab and visit the [Marketplace Portal](https://aws.amazon.com/marketplace/management/homepage).
- [ ] From the top menu bar, click Assets, and from the drop down, select Amazon Machine Image.
- [ ] Click the orange button, that say Add AMI.
- [ ] From the table select the image you want to release, and click next.
- [ ] On the next page in the `IAM Access role ARN` paste this: `arn:aws:iam::239748505547:role/aws_marketplace` and click Next.
- [ ] On this page there is nothing to do, so you can click Next.
- [ ] On the summary page check that all is OK, and click Submit.

Once this process is done, on the Assets > Amazon Machine Images (AMIs) page you will be able to see the status of the scan. you have to wait for the scan to be completed, some time it takes 1h or more.

Once the scan is completed, you can now release the product. By doing the following:

- [ ] In the top menu, click Products, and from the drop down, select Server
- [ ] From the list select the product that you want to update.
- [ ] On the new page, next to the name of the products, you will see a bunch of buttons and drop downs.
- [ ] Select Request Change
  - [ ] From the drop down, select: Update versions
  - [ ] Then select Add new version.
- [ ] On the new page you have to change the following:
  - [ ] Version title: write the version.
  - [ ] Release notes ( copy them from: [](https://www.notion.so/ba8f459abcef479187409dc9fc0713ff))
  - [ ] Amazon machine image (AMI) ID ( the once the you scanned)
  - [ ] IAM access role ARN ( the same as you provided above)
  - [ ] And that is it on this page
- [ ] On the next page don’t change anything, click on `Skip to Review and submit`
- [ ] On the next page click Submit

Once the review is OK, and released by AWS, we have to update the CloudFormation file with the latest AMIs of the product for each region, to do so you have to run a Lambda function that will pull all of this information automatically for you.

- [ ] Go to the Lambda dashboard and run [ami_id_extractor](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/ami_id_extractor?tab=testing).
- [ ] Scroll down until you see the `Event JSON` section.
- [ ] Replace the `id` and the `ami_name` data:
  - [ ] How to get the `id`: click this [link](https://aws.amazon.com/marketplace/management/products/server?#) > select the product that you are updating > in the `Product summary` section you will see: `Product ID`
  - [ ] How to get the `ami_name`: click this [link](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Images:visibility=owned-by-me) > from the table with all the ami, look for the `AMI name` column, and copy and past the name of the product that you are working on.
- [ ] Run the Lambda
- [ ] In the output you will have a JSON that you have to copy and paste in the product CloudFormation file.
- [ ] In the GitHub account: [https://github.com/0x4447-aws-products-cfn](https://github.com/0x4447-aws-products-cfn) you will have all the main CFNs, pick the right product and clone it:
- [ ] On your local machine open your favorite editor and navigate to
  - [ ] 04_Mappings - folder
  - [ ] os_id.json - file
  - [ ] Replace the content from here with what the Lambda from above outputted.
- [ ] Install the [grapes](https://www.npmjs.com/package/@0x4447/grapes) module from NPM.
- [ ] Then in the folder where the repo is, run `grapes -s .` this will regenerate the CloudFormation file with the new values.
- [ ] Now in the folder you will have a `CloudFormation.json` is created, use this file to deploy the stack in AWS for testing. Test the the new image is working as expected, and if all is OK delete the stack, and…
- [ ] Make a new Pull Request (the PR should only have the changes of the ID and nothing else)
- [ ] Mention me in the PR so I get a notification.
- [ ] Merge it with production (this will kick a auto deployment)

And this is it when it comes to releasing, the last thing to do is to check if the official CFN works with the new product. For this do the following:

- [ ] Go to the products page, and pick the product that you are releasing: [https://products.0x4447.com/](https://products.0x4447.com/)
- [ ] Click on the documentation page of the selected product
- [ ] Scroll until the Deployment section
- [ ] Open the source JSON file, and verify that the new ID are in place.
- [ ] In this section there is a link to the RAW CFN file, click it and verify that the new AMI IDs got updated.
- [ ] Go back.
- [ ] And try to deploy the product using the official CFN
- [ ] Once the product is deployed, check that the correct version got deployed
- [ ] Test the main feature of the product
- [ ] Delete the stack when finished.
- [ ] Go to the EC2 Dashboard
- [ ] In the AMI section, rename the AMI to make it the official image with the right version if necessary.

And this is the final step, if all is OK, then the process of releasing is done.
