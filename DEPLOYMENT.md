# Publish Fantasy MPL with GitHub and Vercel

## Before you begin

You need:

- your GitHub account;
- your Vercel account;
- the extracted contents of `fantasy-mpl-vercel.zip`.

Do not upload the ZIP as one compressed file to GitHub. Extract it first, then upload the files and folders inside it.

## 1. Create the GitHub repository

1. Sign in to GitHub.
2. Open **https://github.com/new**.
3. Repository name: `fantasy-mpl`.
4. Choose **Private** while the product is under development.
5. Do not add a README, `.gitignore`, or license because they already exist in the project package.
6. Select **Create repository**.

## 2. Upload the project

On the empty repository page:

1. Select **uploading an existing file**.
2. Extract `fantasy-mpl-vercel.zip` on your computer.
3. Open the extracted folder.
4. Drag all files and folders inside it into GitHub’s upload area. Include `app`, `public`, `package.json`, `package-lock.json`, and the other root files.
5. Wait for every file to finish uploading.
6. Enter commit message: `Initial Fantasy MPL frontend`.
7. Select **Commit changes**.

If GitHub’s browser uploader has trouble with folders, install GitHub Desktop, choose **Add an Existing Repository from your hard drive**, select the extracted folder, publish it as `fantasy-mpl`, and keep it private.

## 3. Deploy through Vercel

1. Sign in at **https://vercel.com**.
2. Select **Add New → Project**.
3. Connect GitHub if Vercel asks for permission.
4. Find and import the `fantasy-mpl` repository.
5. Keep the detected framework as **Next.js**.
6. Leave Root Directory as `./`.
7. Do not add environment variables for this frontend-only release.
8. Select **Deploy**.
9. Wait for Vercel to finish building.
10. Select **Visit** to open your new public URL.

The URL will look similar to:

`https://fantasy-mpl-xxxxx.vercel.app`

## 4. Send back the public URL

Once deployment succeeds, send the Vercel URL back in our conversation. We can then test the public build and continue improvements together.

## What this deployment does not include yet

- secure real-user authentication;
- shared multi-user data;
- permanent cloud predictions;
- database-backed drafts;
- server-side scoring and deadlines.

These will be added after creating a Supabase project.
