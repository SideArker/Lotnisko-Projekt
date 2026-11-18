import { Link, Route, Routes } from "react-router-dom";

export default function App() {
  return (
    <>
      <header>
        <h1>Lotnisko Projekt</h1>
        <nav aria-label="Nawigacja główna">
          <Link to="/">Strona główna</Link>
          <Link to="/about">O projekcie</Link>
        </nav>
      </header>
      <main>
        <Routes>
          <Route path="/" element={<p>chuj chuj chuj .</p>} />
          <Route
            path="/about"
            element={<p>Projekt studencki do nauki Reacta i Spring Boota.</p>}
          />
        </Routes>
      </main>
    </>
  );
}
