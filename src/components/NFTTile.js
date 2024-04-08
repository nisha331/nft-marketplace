import { BrowserRouter as Router, Link } from "react-router-dom";
import { GetIpfsUrlFromPinata } from "../utils";

function NFTTile(data) {
  const newTo = {
    pathname: "/nftPage/" + data.data.tokenId,
  };

  const IPFSUrl = GetIpfsUrlFromPinata(data.data.image);

  return (
    <Link to={newTo} style={{ overflow: "hidden", display: "block" }}>
      <div className="border-4 border-white ml-12 mt-12 mb-8 flex flex-col items-center rounded-xl w-48 md:w-72 shadow-2xl" style={{ overflow: "hidden", display: "block" }}>
        <embed
          src={IPFSUrl}
          alt=""
          className="w-full h-96 rounded-lg object-cover"
          style={{ maxWidth: "100%", minHeight: "100%", objectFit: "cover" }}
        />
      </div>

      <div className="text-white w-full ml-4 mt-4" style={{ overflow: "hidden", display: "block" }}>
        <strong className="text-xl">{data.data.name}</strong>
        <p className="display-inline">{data.data.description}</p>
      </div>
    </Link>
  );
}

export default NFTTile;
