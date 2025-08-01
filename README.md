# Selenium Pytest Docker Project

This project demonstrates how to run a Selenium test using **pytest** and **Python** inside a **Docker** container. You can run tests on both **Chrome** and **Firefox** by building a single, flexible Docker image.

### Project Structure

```
.
├── tests/
│   └── test_google.py       # The core Pytest script with a Selenium test case
├── Dockerfile               # A single Dockerfile to build an image for either Chrome or Firefox
├── requirements.txt         # Python dependencies
└── README.md                # This file
```

### Prerequisites

  * **Docker:** Make sure Docker is installed and running on your machine. You can download it from the [official Docker website](https://www.docker.com/products/docker-desktop).

### 1\. Build the Docker Image

You need to build a Docker image for your desired browser. The `Dockerfile` uses a build argument (`--build-arg BROWSER`) to conditionally install either Chrome or Firefox.

#### To build the Chrome image:

```bash
docker build --build-arg BROWSER=chrome -t selenium-chrome-tests:local .
```

#### To build the Firefox image:

```bash
docker build --build-arg BROWSER=firefox -t selenium-firefox-tests:local .
```

**Explanation:**

  * `docker build`: The command to build a Docker image.
  * `--build-arg BROWSER=...`: Passes the `BROWSER` variable to the `Dockerfile`.
  * `-t selenium-...:local`: Tags the image with a custom name and a `local` tag for easy identification.
  * `.`: Specifies that the build context is the current directory.

### 2\. Run the Tests in a Docker Container

Once the image is built, you can run a container from it. You can specify the test parameters (`URL`, `EXPECTED_TITLE`) by passing them as environment variables using the `-e` flag. The `pytest` command is the default entry point for the container, so it will automatically run your tests.

#### To run tests on Google with Chrome:

```bash
docker run --rm -e BROWSER=chrome -e URL=https://www.google.com -e EXPECTED_TITLE="Google" selenium-chrome-tests:local
```

#### To run tests on DuckDuckGo with Firefox:

```bash
docker run --rm -e BROWSER=firefox -e URL=https://duckduckgo.com -e EXPECTED_TITLE="DuckDuckGo — Privacy, simplified." selenium-firefox-tests:local
```

**Explanation:**

  * `docker run`: The command to run a container from an image.
  * `--rm`: Automatically removes the container once the test run is complete, keeping your system clean.
  * `-e BROWSER=...`: Specifies the browser to be used by the test script inside the container.
  * `-e URL=...`: Sets the URL to be tested.
  * `-e EXPECTED_TITLE=...`: Sets the title the test should verify.
  * `selenium-...:local`: The name of the Docker image you want to run.

You can customize the `URL` and `EXPECTED_TITLE` environment variables for your specific needs.