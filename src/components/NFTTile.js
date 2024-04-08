
import {
    BrowserRouter as Router,
    Link,
  } from "react-router-dom";
  import { GetIpfsUrlFromPinata } from "../utils";

function NFTTile (data) {
    const newTo = {
        pathname:"/nftPage/"+data.data.tokenId
    }

    const IPFSUrl = GetIpfsUrlFromPinata(data.data.image);

    return (
        <Link to={newTo}>
        <div className="border-4 border-white ml-12 mt-5 mb-12 flex flex-col items-center rounded-xl w-48 md:w-72 shadow-2xl">
            <embed
          src={IPFSUrl}
          alt=""
          className="w-full h-96 rounded-lg object-cover"
          style={{ maxWidth: "100%", minHeight: "100%", objectFit: "cover" }}
        />
            <div className= "text-white w-full p-2 bg-gradient-to-t from-[#4c4c4c] to-transparent rounded-lg pt-5 -mt-20">
                <strong className="text-xl">{data.data.name}</strong>
                <p className="display-inline">
                    {data.data.description}
                </p>
            </div>
        </div>
        </Link>
    )
}

export default NFTTile;
