export default function Home() {
  return (
    <>
      <div
        style={{
          backgroundColor: "#A5A5A5FF",
          minHeight: "100vh",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          margin: 0,
          padding: 0,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
          }}
        >
          <h1 style={{ color: "#311b92", fontSize: "2rem" }}>
            Hello from system App
          </h1>
          <a href="/second" style={{ marginTop: "10px" }}>
            go to second page
          </a>
          <a
            href={`${process.env.NEXT_PUBLIC_AWS_URL}`}
            style={{ marginTop: "10px", color: "#EE911FFF" }}
          >
            go to AWS App
          </a>
          <a
            href={`${process.env.NEXT_PUBLIC_GCP_URL}`}
            style={{ marginTop: "10px", color: "#2CA4EAFF" }}
          >
            go to GCP App
          </a>
        </div>
      </div>
    </>
  );
}
