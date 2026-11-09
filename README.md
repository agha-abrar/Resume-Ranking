# Resume Ranking

Resume Ranking is a small Flask web application that helps a hiring team compare a set of PDF resumes against a job description. It extracts resume text, calculates text similarity, sorts candidates from highest to lowest match score, and presents the results in a table with charts.

## What It Can Do

- Accept a job description and multiple PDF resumes in one submission.
- Extract text from PDF files with `pdfminer.six`.
- Preprocess the text and convert it to TF-IDF vectors using the included vectorizer.
- Compare each resume with the job description using cosine similarity.
- Display candidates in ranked order, with a match score and visual comparisons.

The ranking uses the included `tfidf_vectorizer.pkl` and `resume_rank_model.pkl` files. The current ranking code calculates cosine similarity using the vectorizer; the loaded model is required by the app but is not used in that ranking calculation.

## How It Can Help Hiring Teams

For an initial review of a large resume batch, automated sorting can help a recruiter:

- Reduce repetitive first-pass reading and organize resumes for review.
- Find resumes whose wording is more closely aligned with a role description.
- Compare a batch using the same text-matching method.
- Spend more time evaluating promising candidates and less time sorting files.

Treat the ranking as a review aid, not a screening or hiring decision. Text similarity can miss relevant experience expressed differently, favor keyword overlap, and reflect limitations in the data and model used to build the vectorizer. The displayed percentage is a scaled cosine-similarity score, not a probability of job performance or a calibrated qualification percentage. Have a human review the original resumes and use consistent, job-related criteria for every candidate.

## Requirements

- Python 3.9 or a compatible Python version. The provided Docker image uses Python 3.9.
- `pip` to install the Python packages in `requirements.txt`.
- The model and vectorizer files in the project root:
  - `resume_rank_model.pkl`
  - `tfidf_vectorizer.pkl`
- Internet access on the first application start so NLTK can download its English stopwords corpus.
- Docker, if you prefer to run the container instead of installing Python dependencies locally.

## Run Locally

From the project directory, create and activate a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install the dependencies and start the Flask app:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python app.py
```

On first start, NLTK downloads the stopwords corpus. When the server is ready, open [http://127.0.0.1:5000](http://127.0.0.1:5000), paste a job description, choose one or more PDF resumes, and select **Rank candidates**.

Stop the local server with `Ctrl+C`.

## Run With Docker

Build the image from the project root, then run it:

```bash
docker build -t resume-ranking .
docker run --rm -p 5000:5000 resume-ranking
```

Open [http://127.0.0.1:5000](http://127.0.0.1:5000). The container needs network access on first start for NLTK stopwords. The app writes uploaded resumes to `uploads/` inside the container; with `--rm`, those files are removed when the container stops. For local persistence, mount a host directory at `/app/uploads`, for example:

```bash
docker run --rm -p 5000:5000 -v "$(pwd)/uploads:/app/uploads" resume-ranking
```

## Project Files

| Path | Purpose |
| --- | --- |
| `app.py` | Flask routes, PDF text extraction, preprocessing, and ranking logic |
| `templates/dashboard.html` | Resume upload form and ranked-results dashboard |
| `requirements.txt` | Python package dependencies |
| `tfidf_vectorizer.pkl` | Serialized TF-IDF vectorizer used to transform text |
| `resume_rank_model.pkl` | Serialized model loaded by the application |
| `uploads/` | Directory where uploaded PDF files are stored |
| `Dockerfile` | Container image configuration |

## Privacy and Deployment Notes

- Uploaded resumes contain personal information. Use only data you are authorized to process, and define appropriate retention and access controls.
- The app saves uploaded PDFs in `uploads/` and does not automatically delete them. Remove files according to your organization's retention policy.
- The current app has no authentication, authorization, upload-size limit, or production server configuration. Do not expose it directly to the public internet or use it as-is for production hiring.
- `app.py` starts Flask with debug mode enabled. Debug mode is intended for local development only; disable it and run behind a production-ready WSGI server before any controlled deployment.
- Keep the serialized `.pkl` files trusted: loading pickle/joblib files from an untrusted source can execute code.
- Chart.js and Font Awesome are loaded from public CDNs by the dashboard, so the browser needs network access to display those assets.

## Troubleshooting

- **Missing model or vectorizer:** Ensure both `.pkl` files are in the project root alongside `app.py`.
- **NLTK download fails:** Check network access and try starting the app again after connectivity is restored.
- **No results appear:** Upload readable PDF files with extractable text. Scanned/image-only PDFs may not contain text for the current extractor to rank.
- **Model loading errors:** Serialized scikit-learn artifacts can depend on the package versions used when they were created. Use compatible versions of scikit-learn and related packages if loading fails.