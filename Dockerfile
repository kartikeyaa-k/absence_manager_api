# Build Stage
FROM dart:stable AS builder
WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

RUN dart pub global activate dart_frog_cli

COPY . .
RUN dart_frog build
RUN dart compile exe build/bin/server.dart -o server

# Runtime Stage 
FROM dart:stable AS runner
WORKDIR /app

# Copy over AOT’d server and data files
COPY --from=builder /app/server .
COPY --from=builder /app/data ./data

EXPOSE 8080

CMD ["./server", "--port", "8080", "--hostname", "0.0.0.0"]
