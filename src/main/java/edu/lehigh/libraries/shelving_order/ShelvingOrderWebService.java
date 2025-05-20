package edu.lehigh.libraries.shelving_order;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Application;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;

import org.marc4j.callnum.DeweyCallNumber;

@Path("/shelf-key")
public class ShelvingOrderWebService extends Application {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public Response processString(@QueryParam("callNumber") String inputCallNumber) {
        if (inputCallNumber == null) {
            return Response.status(Status.BAD_REQUEST)
                .entity("callNumber query parameter is required")
                .build();
        }

        DeweyCallNumber callNumber = new DeweyCallNumber(inputCallNumber);
        String shelfKey = callNumber.getShelfKey();
        return Response.ok(shelfKey).build();
    }
}
