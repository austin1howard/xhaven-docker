# Download and unzip the built release file in alpine
FROM alpine:latest as download

WORKDIR /download

RUN apk update
RUN apk add wget unzip

# Download linux build from github
ARG RELEASE_URL=https://github.com/Tarmslitaren/FrosthavenAssistant/releases/download/1.8.7/x_haven_assistant_1.8.7_ubuntu.zip
RUN wget $RELEASE_URL -O xhaven-assistant.zip

# Unzip it to a subdir
RUN unzip xhaven-assistant.zip -d xhaven-assistant



# For the runtime image, I don't want to deal with alpine
FROM ubuntu:latest as runtime

WORKDIR /app

# Including x11-apps for debugging and to ensure all libs are present
RUN apt-get update -y && \
	apt-get install -y \
		x11-apps \
		wget \
		libgtk-3-0 \
		&& \
	apt-get clean

# Copy over downloaded files
COPY --from=download /download/xhaven-assistant/bundle /app/xhaven-assistant

# chmod the main executable
RUN chmod a+x /app/xhaven-assistant/frosthaven_assistant

# Set up entrypoint.sh script for running it
COPY entrypoint.sh .
RUN chmod a+x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]