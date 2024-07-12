export const objectCleaner = (obj: object) => {
  for (const propName in obj) {
    if (
      obj[propName as keyof object] === null ||
      obj[propName as keyof object] === undefined ||
      obj[propName as keyof object] === ""
    ) {
      delete obj[propName as keyof object];
    }
  }
  return obj;
};

export function convertToAMPM(time24: string) {
  // Split the input string into hours and minutes
  let [hours, minutes] = time24.split(":");
  hours = parseInt(hours);
  minutes = parseInt(minutes);

  // Determine AM or PM suffix
  let suffix = hours >= 12 ? "PM" : "AM";

  // Convert hours from 24-hour to 12-hour format
  hours = hours % 12;
  hours = hours ? hours : 12; // the hour '0' should be '12'

  // Return the formatted time
  return `${hours}:${minutes < 10 ? "0" + minutes : minutes} ${suffix}`;
}
